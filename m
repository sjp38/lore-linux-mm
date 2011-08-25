Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 647466B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 10:07:05 -0400 (EDT)
Date: Thu, 25 Aug 2011 16:07:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmotm 2011-08-24-14-08 uploaded
Message-ID: <20110825140701.GA6838@tiehlicka.suse.cz>
References: <201108242148.p7OLm1lt009191@imap1.linux-foundation.org>
 <20110825135103.GA6431@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110825135103.GA6431@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Thu 25-08-11 15:51:03, Michal Hocko wrote:
> Hi Andrew,
> 
> On Wed 24-08-11 14:09:05, Andrew Morton wrote:
> > The mm-of-the-moment snapshot 2011-08-24-14-08 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> 
> I have just downloaded your tree and cannot quilt it up. I am getting:
> [...]
> patching file tools/power/cpupower/debug/x86_64/centrino-decode.c
> Hunk #1 FAILED at 1.
> File tools/power/cpupower/debug/x86_64/centrino-decode.c is not empty after patch, as expected
> 1 out of 1 hunk FAILED -- rejects in file tools/power/cpupower/debug/x86_64/centrino-decode.c
> patching file tools/power/cpupower/debug/x86_64/powernow-k8-decode.c
> Hunk #1 FAILED at 1.
> File tools/power/cpupower/debug/x86_64/powernow-k8-decode.c is not empty after patch, as expected
> 1 out of 1 hunk FAILED -- rejects in file tools/power/cpupower/debug/x86_64/powernow-k8-decode.c
> [...]
> patching file virt/kvm/iommu.c
> Patch linux-next.patch does not apply (enforce with -f)
> 
> Is this a patch (I am using 2.6.1) issue? The failing hunk looks as
> follows:
> --- a/tools/power/cpupower/debug/x86_64/centrino-decode.c
> +++ /dev/null
> @@ -1 +0,0 @@
> -../i386/centrino-decode.c
> \ No newline at end of file

Isn't this just a special form of git (clever) diff to spare some lines
when the file deleted? Or is the patch simply corrupted?
Anyway, my patch doesn't cope with that. Any hint what to do about it?

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
