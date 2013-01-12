Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id B61BB6B0071
	for <linux-mm@kvack.org>; Sat, 12 Jan 2013 10:47:35 -0500 (EST)
Date: Sat, 12 Jan 2013 16:47:32 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <20130111234813.170A620004E@hpza10.eem.corp.google.com>
In-Reply-To: <20130111234813.170A620004E@hpza10.eem.corp.google.com>
Message-ID: <50F18594.7070004@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: mmotm 2013-01-11-15-47 (trouble starting kvm)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On 12.01.2013 00:48, akpm@linux-foundation.org wrote:
> A git tree which contains the memory management portion of this tree is
> maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> by Michal Hocko.  It contains the patches which are between the

The last commit I see in this tree is:

commit a0d271cbfed1dd50278c6b06bead3d00ba0a88f9
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sun Sep 30 16:47:46 2012 -0700

     Linux 3.6

Is it dead? Or am I doing something wrong?

> A full copy of the full kernel tree with the linux-next and mmotm patches
> already applied is available through git within an hour of the mmotm
> release.  Individual mmotm releases are tagged.  The master branch always
> points to the latest release, so it's constantly rebasing.
>
> http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary
>
> This mmotm tree contains the following patches against 3.8-rc3:
> (patches marked "*" will be included in linux-next)
>
> * lockdep-rwsem-provide-down_write_nest_lock.patch
> * mm-mmap-annotate-vm_lock_anon_vma-locking-properly-for-lockdep.patch

Had to revert the above two patches to start KVM (win7) successfully. 
Otherwise it would livelock on some semaphore, it seems. Couldn't kill 
it, ps output would stuck, even reboot didn't work (had to use SysRQ).

-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
