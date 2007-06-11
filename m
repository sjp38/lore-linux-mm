Date: Mon, 11 Jun 2007 11:11:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] shm: Fix the filename of hugetlb sysv shared memory
Message-Id: <20070611111111.2345470d.akpm@linux-foundation.org>
In-Reply-To: <m1vedyqaft.fsf_-_@ebiederm.dsl.xmission.com>
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	<20070606204432.b670a7b1.akpm@linux-foundation.org>
	<787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
	<20070607162004.GA27802@vino.hallyn.com>
	<m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com>
	<46697EDA.9000209@us.ibm.com>
	<m1vedyqaft.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, Albert Cahalan <acahalan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 08 Jun 2007 17:43:34 -0600
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Some user space tools need to identify SYSV shared memory when
> examining /proc/<pid>/maps.  To do so they look for a block device
> with major zero, a dentry named SYSV<sysv key>, and having the minor of
> the internal sysv shared memory kernel mount.
> 
> To help these tools and to make it easier for people just browsing
> /proc/<pid>/maps this patch modifies hugetlb sysv shared memory to
> use the SYSV<key> dentry naming convention.
> 
> User space tools will still have to be aware that hugetlb sysv
> shared memory lives on a different internal kernel mount and so
> has a different block device minor number from the rest of sysv
> shared memory.

So..  I am sitting here believing that this patch and Badari's
restore-shmid-as-inode-to-fix-proc-pid-maps-abi-breakage.patch are both
needed in 2.6.22 and that they will fix all these issues up.

If that is untrue, someone please let us know..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
