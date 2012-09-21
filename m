Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 8BD306B002B
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 05:19:52 -0400 (EDT)
Message-ID: <505C306F.2000601@parallels.com>
Date: Fri, 21 Sep 2012 13:16:31 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: MMTests 0.05
References: <20120907124232.GA11266@suse.de> <505AF81C.1080404@parallels.com> <20120920153705.GQ11266@suse.de>
In-Reply-To: <20120920153705.GQ11266@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 09/20/2012 07:37 PM, Mel Gorman wrote:
> On Thu, Sep 20, 2012 at 03:03:56PM +0400, Glauber Costa wrote:
>> On 09/07/2012 04:42 PM, Mel Gorman wrote:
>>> ./run-mmtests.sh test-run-1
>>
>> Mel, would you share with us the command line and config tweaks you had
>> in place to run the memcg tests you presented in the memcg summit?
>>
> 
> Apply the following patch to mmtests 0.05 and then from within the
> mmtests directory do
> 
> ./run-mmtests.sh testrun
> 
> At the very least you should have oprofile installed. Optionally install
> libnuma-devel but the test will cope if it's not available. Automatic package
> installation will be in 0.06 for opensuse at least but other distros can
> be easily supported if I know the names of the equivalent packages.
> 
> The above command will run both with and without profiling. The profiles
> will be in work/log/pft-testrun/fine-profile-timer/base/ and an annotated
> profile will be included in the file. If you have "recode" installed the
> annotated profile will be compressed and can be extracted with something like
> 
> grep -A 9999999 "=== annotate ===" oprofile-compressed.report | grep -v annotate | recode /b64..char | gunzip -c
> 
> Each of the memcg functions will be small but when all the functions that
> are in mm/memcontrol.c are added together it becomes a big problem.  What I
> actually showed at the meeting was based on piping the oprofile report
> through another quick and dirty script to match functions to filenames.
> 
> The bulk of this patch is renaming  profile-disabled-hooks-a.sh to
> profile-hooks-a.sh. Let me know if you run into problems.

FYI: I get this:

Can't locate TLBC/Report.pm in @INC (@INC contains:
/home/glauber/mmtests-0.05-mmtests-0.01/vmr/bin /usr/local/lib64/perl5
/usr/local/share/perl5 /usr/lib64/perl5/vendor_perl
/usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at
/home/glauber/mmtests-0.05-mmtests-0.01/vmr/bin/oprofile_map_events.pl
line 11.

Investigating, it seems that hugetlbfs packages in fedora doesn't
install any perl scripts, unlike SuSE.

I downloaded the library manually, and pointed perl path to it, and it
seems to work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
