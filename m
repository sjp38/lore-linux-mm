Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id C671F6B0006
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 02:10:11 -0400 (EDT)
Message-ID: <516CEBA6.9060703@sr71.net>
Date: Mon, 15 Apr 2013 23:11:50 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RESEND] IOZone with transparent huge page cache
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com> <20130415181718.4A1A1E0085@blue.fi.intel.com> <516C8B03.7040203@sr71.net> <20130416055721.B8415E0085@blue.fi.intel.com>
In-Reply-To: <20130416055721.B8415E0085@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 04/15/2013 10:57 PM, Kirill A. Shutemov wrote:
>>> > > ** Initial writers **
>>> > > threads:	        1        2        4        8       16       32       64      128      256
>>> > > baseline:	  1103360   912585   500065   260503   128918    62039    34799    18718     9376
>>> > > patched:	  2127476  2155029  2345079  1942158  1127109   571899   127090    52939    25950
>>> > > speed-up(times):     1.93     2.36     4.69     7.46     8.74     9.22     3.65     2.83     2.77
>> > 
>> > I'm a _bit_ surprised that iozone scales _that_ badly especially while
>> > threads<nr_cpus.  Is this normal for iozone?  What are the units and
>> > metric there, btw?
> The units is KB/sec per process (I used 'Avg throughput per process' from
> iozone report). So it scales not that badly.
> I will use total children throughput next time to avoid confusion.

Wow.  Well, it's cool that your patches just fix it up inherently.  I'd
still really like to see some analysis exactly where the benefit is
coming from though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
