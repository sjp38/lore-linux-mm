Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id CDB496B007E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 21:00:14 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id k2so72166235vkb.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 18:00:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h190si34097001qkc.51.2016.06.17.18.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 18:00:13 -0700 (PDT)
Subject: Re: [RFC 12/18] limits: track RLIMIT_MEMLOCK actual max
References: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
 <1465847065-3577-13-git-send-email-toiwoton@gmail.com>
From: Doug Ledford <dledford@redhat.com>
Message-ID: <3927ff64-d067-7f27-14ef-d1ab453c3cfb@redhat.com>
Date: Fri, 17 Jun 2016 20:59:13 -0400
MIME-Version: 1.0
In-Reply-To: <1465847065-3577-13-git-send-email-toiwoton@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="6WsKfN53rt9UP70qxGQSG9CoHGX0Sw6Wq"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Topi Miettinen <toiwoton@gmail.com>, linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Alexei Starovoitov <ast@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Jiri Slaby <jslaby@suse.cz>, Cyrill Gorcunov <gorcunov@openvz.org>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Nikhil Rao <nikhil.rao@intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM) FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM)" <kvm@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:BPF (Safe dynamic programs and tools)" <netdev@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6WsKfN53rt9UP70qxGQSG9CoHGX0Sw6Wq
Content-Type: multipart/mixed; boundary="FJ9LmdXOk3jsSnbI0w6IN1wICkUXWh9uU"
From: Doug Ledford <dledford@redhat.com>
To: Topi Miettinen <toiwoton@gmail.com>, linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
 Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>,
 =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock
 <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>,
 Dennis Dalessandro <dennis.dalessandro@intel.com>,
 Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>,
 Sudeep Dutt <sudeep.dutt@intel.com>,
 Ashutosh Dixit <ashutosh.dixit@intel.com>,
 Alex Williamson <alex.williamson@redhat.com>, Ingo Molnar
 <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Alexei Starovoitov <ast@kernel.org>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Konstantin Khlebnikov <koct9i@gmail.com>, Jiri Slaby <jslaby@suse.cz>,
 Cyrill Gorcunov <gorcunov@openvz.org>, Thomas Gleixner <tglx@linutronix.de>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Dan Carpenter <dan.carpenter@oracle.com>, Nikhil Rao <nikhil.rao@intel.com>,
 Vlastimil Babka <vbabka@suse.cz>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Michal Hocko <mhocko@suse.com>, Eric B Munson <emunson@akamai.com>,
 Alexey Klimov <klimov.linux@gmail.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Alexander Kuleshov <kuleshovmail@gmail.com>, Oleg Nesterov
 <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>,
 Laurent Dufour <ldufour@linux.vnet.ibm.com>,
 "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>,
 "open list:KERNEL VIRTUAL MACHINE (KVM) FOR POWERPC"
 <kvm-ppc@vger.kernel.org>,
 "open list:KERNEL VIRTUAL MACHINE (KVM)" <kvm@vger.kernel.org>,
 "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)"
 <linuxppc-dev@lists.ozlabs.org>,
 "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>,
 "open list:BPF (Safe dynamic programs and tools)" <netdev@vger.kernel.org>,
 "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>
Message-ID: <3927ff64-d067-7f27-14ef-d1ab453c3cfb@redhat.com>
Subject: Re: [RFC 12/18] limits: track RLIMIT_MEMLOCK actual max
References: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
 <1465847065-3577-13-git-send-email-toiwoton@gmail.com>
In-Reply-To: <1465847065-3577-13-git-send-email-toiwoton@gmail.com>

--FJ9LmdXOk3jsSnbI0w6IN1wICkUXWh9uU
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 6/13/2016 3:44 PM, Topi Miettinen wrote:
> Track maximum size of locked memory, presented in /proc/self/limits.

You should have probably Cc:ed everyone on the cover letter and probably
patch 1 of this series.  This patch is hard to decipher without the
additional context of those items.  However, that said, I think I see
what you are doing.  But your wording of your comments below is bad:

> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index feb9bb7..d3f3c9f 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -3378,10 +3378,16 @@ static inline unsigned long rlimit_max(unsigned=
 int limit)
>  	return task_rlimit_max(current, limit);
>  }
> =20
> +static inline void task_bump_rlimit(struct task_struct *tsk,
> +				    unsigned int limit, unsigned long r)
> +{
> +	if (READ_ONCE(tsk->signal->rlim_curmax[limit]) < r)
> +		tsk->signal->rlim_curmax[limit] =3D r;
> +}
> +
>  static inline void bump_rlimit(unsigned int limit, unsigned long r)
>  {
> -	if (READ_ONCE(current->signal->rlim_curmax[limit]) < r)
> -		current->signal->rlim_curmax[limit] =3D r;
> +	return task_bump_rlimit(current, limit, r);
>  }
> =20
>  #ifdef CONFIG_CPU_FREQ
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 46ecce4..192001e 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -76,6 +76,9 @@ static int bpf_map_charge_memlock(struct bpf_map *map=
)
>  		return -EPERM;
>  	}
>  	map->user =3D user;
> +	/* XXX resource limits apply per task, not per user */
> +	bump_rlimit(RLIMIT_MEMLOCK, atomic_long_read(&user->locked_vm) <<
> +		    PAGE_SHIFT);

No, these resource limits do not apply per task.  They are per user.
However, you are doing maximum  usage accounting on a per-task basis by
adding a new counter to the signal struct of the task.  Fine, but your
comments need to reflect that instead of the confusing comment above.
In addition, your function name is horrible for what you are doing.  A
person reading this function will think that you are bumping the actual
rlimit on the task, which is not what you are doing.  You are performing
per-task accounting of MEMLOCK memory.  The actual permission checks are
per-user, and the primary accounting is per-user.  So, really, this is
just a nice little feature that provides a more granular per-task usage
(but not control) so a user can see where their overall memlock memory
is being used.  Fine.  I would reword the comment something like this:

/* XXX resource is tracked and limit enforced on a per user basis,
   but we track it on a per-task basis as well so users can identify
   hogs of this resource, stats can be found in /proc/<pid>/limits */

And I would rename bump_rlimit and task_bump_rlimit to something like
account_rlimit and task_account_rlimit.  Calling it bump just gives the
wrong idea entirely on first read.

>  	return 0;
>  }
> =20
> @@ -601,6 +604,9 @@ static int bpf_prog_charge_memlock(struct bpf_prog =
*prog)
>  		return -EPERM;
>  	}
>  	prog->aux->user =3D user;
> +	/* XXX resource limits apply per task, not per user */
> +	bump_rlimit(RLIMIT_MEMLOCK, atomic_long_read(&user->locked_vm) <<
> +		    PAGE_SHIFT);
>  	return 0;
>  }

> @@ -798,6 +802,9 @@ int user_shm_lock(size_t size, struct user_struct *=
user)
>  	get_uid(user);
>  	user->locked_shm +=3D locked;
>  	allowed =3D 1;
> +
> +	/* XXX resource limits apply per task, not per user */
> +	bump_rlimit(RLIMIT_MEMLOCK, user->locked_shm << PAGE_SHIFT);
>  out:
>  	spin_unlock(&shmlock_user_lock);
>  	return allowed;
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 0963e7f..4e683dd 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2020,6 +2020,9 @@ static int acct_stack_growth(struct vm_area_struc=
t *vma, unsigned long size, uns
>  		return -ENOMEM;
> =20
>  	bump_rlimit(RLIMIT_STACK, actual_size);
> +	if (vma->vm_flags & VM_LOCKED)
> +		bump_rlimit(RLIMIT_MEMLOCK,
> +			    (mm->locked_vm + grow) << PAGE_SHIFT);
> =20
>  	return 0;
>  }
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 1f157ad..ade3e13 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -394,6 +394,9 @@ static struct vm_area_struct *vma_to_resize(unsigne=
d long addr,
>  		*p =3D charged;
>  	}
> =20
> +	if (vma->vm_flags & VM_LOCKED)
> +		bump_rlimit(RLIMIT_MEMLOCK, (mm->locked_vm << PAGE_SHIFT) +
> +			    new_len - old_len);
>  	return vma;
>  }
> =20
>=20


--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--FJ9LmdXOk3jsSnbI0w6IN1wICkUXWh9uU--

--6WsKfN53rt9UP70qxGQSG9CoHGX0Sw6Wq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXZJzhAAoJELgmozMOVy/dF44QAJwDqgSkgShvG1A4nZKeKF2A
UHIMF2u+LvY1TMQHHx7wFxW+Pjq55yZvT5puQT7+cyqpv8EzuYq9KtmysYvHy731
EYg213+tFFh7lgccQimkcMsVZHm/h7bIemTzZMVLO5DMD5+0T4WUfQf5i5y1bOta
EBApW5hXSxlJgHe06ozOsjBhZhz2SxvtmeRxs8Zk/odbVJ9K9g5oyma2ixpSsDbK
ghwycsYIuysKTZ9tRqhaDWjcTYbs71HDzPtDZPGql61+dWqyHYvb9919AfDIuyMx
qLJLCuliJtwH5O0JFy+T8xmPhSCIFtVUFj4DTwwvuf1TdK3LSQrtkkZ6wYYPiEdg
/CWh5PTppyICfCAz1gLg6WYAoi7ZwBfNPW8K6Aa8jGuUnTWMHr6XwaQXV0l5YZkF
dST8PzU2tV1a+mMHbMaXWucUrzBygZ1k1xZ/BXNYUO9LAoGy55OJxl88IsTqJoZk
XGoXtIBHWRViybRCjgIf3/KUNUdlHqp/vtCUstxj3iG1F/eoxHVuVBoDuJtt4QgN
eawqW76OLizYoyVDC4uH5i1kzf+HNihE8hvBZvEwD9JHvf/kI/zAXEd30ummAQMS
sgZW1LQMaLcyg8A+z7cyg8+MhHM79nJqhGmaGL/yTJ9CDs+HndqwyrjsXATOrkU7
Rc5joC6vtw2XHW2v41Gq
=NDfl
-----END PGP SIGNATURE-----

--6WsKfN53rt9UP70qxGQSG9CoHGX0Sw6Wq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
