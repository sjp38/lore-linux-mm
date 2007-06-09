From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] shm: Fix the filename of hugetlb sysv shared memory
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	<20070606204432.b670a7b1.akpm@linux-foundation.org>
	<787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
	<20070607162004.GA27802@vino.hallyn.com>
	<m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com>
	<46697EDA.9000209@us.ibm.com>
	<m1vedyqaft.fsf_-_@ebiederm.dsl.xmission.com>
	<20070608165505.aa15fcdb.akpm@linux-foundation.org>
	<466A2D4F.3040300@us.ibm.com>
Date: Sat, 09 Jun 2007 02:01:35 -0600
In-Reply-To: <466A2D4F.3040300@us.ibm.com> (Badari Pulavarty's message of
	"Fri, 08 Jun 2007 21:32:15 -0700")
Message-ID: <m1r6olr1y8.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Serge E. Hallyn" <serge@hallyn.com>, Albert Cahalan <acahalan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> writes:

> No. You still need my patch to fix the current breakage.

Agreed.

> This patch makes hugetlbfs also use same naming convention as regular shmem for
> its
> name. This is not absolutely needed, its a nice to have. Currently, user space
> tools
> can't depend on the filename alone, since its not unique (based on kry).

Exactly.  My patch is an additional fix/cleanup to bring the hugetlbfs
shm segments as close to their normal counterparts as I can.

pmap still won't recognize them as shm segments (different block device
minor number) but otherwise they are now presented identically with
normal shm segments.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
