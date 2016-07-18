Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 833256B0005
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 17:25:33 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a123so417349371qkd.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 14:25:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h7si17533807qkd.252.2016.07.18.14.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 14:25:32 -0700 (PDT)
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
 <5788F0E1.8090203@nod.at>
From: Doug Ledford <dledford@redhat.com>
Message-ID: <ac74d6f7-8972-feae-8e7f-696b46386349@redhat.com>
Date: Mon, 18 Jul 2016 17:25:09 -0400
MIME-Version: 1.0
In-Reply-To: <5788F0E1.8090203@nod.at>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="M3ixGbs6cpxcT1XHlVgIucud5P4hN5WcC"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>, Topi Miettinen <toiwoton@gmail.com>, linux-kernel@vger.kernel.org
Cc: Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Alexei Starovoitov <ast@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Balbir Singh <bsingharora@gmail.com>, Markus Elfring <elfring@users.sourceforge.net>, "David S. Miller" <davem@davemloft.net>, Nicolas Dichtel <nicolas.dichtel@6wind.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Jiri Slaby <jslaby@suse.cz>, Cyrill Gorcunov <gorcunov@openvz.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Michael Kerrisk <mtk.manpages@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Marcus Gelderie <redmnic@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Joe Perches <joe@perches.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <ak@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Stas Sergeev <stsp@list.ru>, Amanieu d'Antras <amanieu@gmail.com>, Wang Xiaoqiang <wangxq10@lzu.edu.cn>, Helge Deller <deller@gmx.de>, Mateusz Guzik <mguzik@redhat.com>, Alex Thorlton <athorlton@sgi.com>, Ben Segall <bsegall@google.com>, John Stultz <john.stultz@linaro.org>, Rik van Riel <riel@redhat.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM) FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM)" <kvm@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:FILESYSTEMS (VFS and infrastructure)" <linux-fsdevel@vger.kernel.org>, "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>, "open list:BPF (Safe dynamic programs and tools)" <netdev@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--M3ixGbs6cpxcT1XHlVgIucud5P4hN5WcC
Content-Type: multipart/mixed; boundary="8frEMwdTsgB3uuLViGNWprrwlex3S9Tn0"
From: Doug Ledford <dledford@redhat.com>
To: Richard Weinberger <richard@nod.at>, Topi Miettinen <toiwoton@gmail.com>,
 linux-kernel@vger.kernel.org
Cc: Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>,
 Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?=
 <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>,
 "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>,
 Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock
 <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>,
 Dennis Dalessandro <dennis.dalessandro@intel.com>,
 Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>,
 Sudeep Dutt <sudeep.dutt@intel.com>,
 Ashutosh Dixit <ashutosh.dixit@intel.com>,
 Alex Williamson <alex.williamson@redhat.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>,
 Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Peter Zijlstra <peterz@infradead.org>, Alexei Starovoitov <ast@kernel.org>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 Balbir Singh <bsingharora@gmail.com>,
 Markus Elfring <elfring@users.sourceforge.net>,
 "David S. Miller" <davem@davemloft.net>,
 Nicolas Dichtel <nicolas.dichtel@6wind.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Konstantin Khlebnikov <koct9i@gmail.com>, Jiri Slaby <jslaby@suse.cz>,
 Cyrill Gorcunov <gorcunov@openvz.org>, Michal Hocko <mhocko@suse.com>,
 Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Dan Carpenter <dan.carpenter@oracle.com>,
 Michael Kerrisk <mtk.manpages@gmail.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Marcus Gelderie <redmnic@gmail.com>,
 Vladimir Davydov <vdavydov@virtuozzo.com>, Joe Perches <joe@perches.com>,
 Frederic Weisbecker <fweisbec@gmail.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen
 <ak@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>,
 Stas Sergeev <stsp@list.ru>, Amanieu d'Antras <amanieu@gmail.com>,
 Wang Xiaoqiang <wangxq10@lzu.edu.cn>, Helge Deller <deller@gmx.de>,
 Mateusz Guzik <mguzik@redhat.com>, Alex Thorlton <athorlton@sgi.com>,
 Ben Segall <bsegall@google.com>, John Stultz <john.stultz@linaro.org>,
 Rik van Riel <riel@redhat.com>, Eric B Munson <emunson@akamai.com>,
 Alexey Klimov <klimov.linux@gmail.com>, Chen Gang
 <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
 David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>,
 Alexander Kuleshov <kuleshovmail@gmail.com>,
 "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
 "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>,
 "open list:KERNEL VIRTUAL MACHINE (KVM) FOR POWERPC"
 <kvm-ppc@vger.kernel.org>,
 "open list:KERNEL VIRTUAL MACHINE (KVM)" <kvm@vger.kernel.org>,
 "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)"
 <linuxppc-dev@lists.ozlabs.org>,
 "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>,
 "open list:FILESYSTEMS (VFS and infrastructure)"
 <linux-fsdevel@vger.kernel.org>,
 "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
 "open list:BPF (Safe dynamic programs and tools)" <netdev@vger.kernel.org>,
 "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>
Message-ID: <ac74d6f7-8972-feae-8e7f-696b46386349@redhat.com>
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
 <5788F0E1.8090203@nod.at>
In-Reply-To: <5788F0E1.8090203@nod.at>

--8frEMwdTsgB3uuLViGNWprrwlex3S9Tn0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable

On 7/15/2016 10:19 AM, Richard Weinberger wrote:
> Hi!
>=20
> Am 15.07.2016 um 12:35 schrieb Topi Miettinen:
>> Hello,
>>
>> There are many basic ways to control processes, including capabilities=
,
>> cgroups and resource limits. However, there are far fewer ways to find=
 out
>> useful values for the limits, except blind trial and error.
>>
>> This patch series attempts to fix that by giving at least a nice start=
ing
>> point from the highwater mark values of the resources in question.
>> I looked where each limit is checked and added a call to update the ma=
rk
>> nearby.
>>
>> Example run of program from Documentation/accounting/getdelauys.c:
>>
>> ./getdelays -R -p `pidof smartd`
>> printing resource accounting
>> RLIMIT_CPU=3D0
>> RLIMIT_FSIZE=3D0
>> RLIMIT_DATA=3D18198528
>> RLIMIT_STACK=3D135168
>> RLIMIT_CORE=3D0
>> RLIMIT_RSS=3D0
>> RLIMIT_NPROC=3D1
>> RLIMIT_NOFILE=3D55
>> RLIMIT_MEMLOCK=3D0
>> RLIMIT_AS=3D130879488
>> RLIMIT_LOCKS=3D0
>> RLIMIT_SIGPENDING=3D0
>> RLIMIT_MSGQUEUE=3D0
>> RLIMIT_NICE=3D0
>> RLIMIT_RTPRIO=3D0
>> RLIMIT_RTTIME=3D0
>>
>> ./getdelays -R -C /sys/fs/cgroup/systemd/system.slice/smartd.service/
>> printing resource accounting
>> sleeping 1, blocked 0, running 0, stopped 0, uninterruptible 0
>> RLIMIT_CPU=3D0
>> RLIMIT_FSIZE=3D0
>> RLIMIT_DATA=3D18198528
>> RLIMIT_STACK=3D135168
>> RLIMIT_CORE=3D0
>> RLIMIT_RSS=3D0
>> RLIMIT_NPROC=3D1
>> RLIMIT_NOFILE=3D55
>> RLIMIT_MEMLOCK=3D0
>> RLIMIT_AS=3D130879488
>> RLIMIT_LOCKS=3D0
>> RLIMIT_SIGPENDING=3D0
>> RLIMIT_MSGQUEUE=3D0
>> RLIMIT_NICE=3D0
>> RLIMIT_RTPRIO=3D0
>> RLIMIT_RTTIME=3D0
>>
>> In this example, smartd is running as a non-root user. The presented
>> values can be used as a starting point for giving new limits to the
>> service.
>=20
> I don't think it is worth sprinkling the kernel with update_resource_hi=
ghwatermark()
> calls just to get these metrics.
>=20
> Can't we teach the existing perf infrastructure to collect these highwa=
termarks for us?

I'm not sure about perf (I don't know the internals of perf well enough
to comment), but I'm sure the systemtap infrastructure could do this,
and a preconfigured systemtap script could be shipped with the package
that would allow this.


--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--8frEMwdTsgB3uuLViGNWprrwlex3S9Tn0--

--M3ixGbs6cpxcT1XHlVgIucud5P4hN5WcC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXjUk1AAoJELgmozMOVy/dP3IP/0hyIoxdsn8gLJYXycXi6cLC
/tgtRfkmEm93ThsKdpY398nopgmsonKaSOACfmsQeH6iiTz6n39jQe/kkAWoYekV
iwfri7KBDuC2c8EHHPSgPtMEV1NaG2GPO8HiR7ai2IiKXPfLHTpF6IUW08jCKCot
WnSF47svlaWU6lzsx2OSlzDVzxmMx/cVyAVU+mgsgsX1TjSuWlTC89UHf/pbsMAG
8+9pKyuR6WbdQfl7/n7z86MA5ElFWA/WkkWVkrtkfUaLS1SAhqS4Y6/7+HTXkkgL
deUgXCrXpfFuUezUEOuU50jejfG4KyX2xlQmQuxB/AbzSb/GlnBNMSg6RFUJt/uD
VRIV5oedBGTsnvGmzB3rURG6JhpZEbe3FGh+sGx40GxQgdqn5QPCixljiw8rBR76
+yibZeaVEiBHtTJjiXzYe0kt3KmquzMvIC0alv/0lw8BMLMokBhfd2j97yL9qcvs
2DHTJxYcWFxzv6HFPxKYLoqUphTAfwYaQILwqdQtLD7VCvfjpBvqo5bCr2o/ZWeS
w7SFIhlHvKvr5rDT7aLUXbs7AiXDQM5MX1NL7K/8eFhzogpDTPwQUiPVQpZ4nTjl
o1KtYhLFdjnEDIgxDBvxSPZLH8xSm9bwkbJDvBc+BeJF8irRZnkQGLr7Gmwto3mu
CuW23JN0mA7RnFIRKsr6
=umnq
-----END PGP SIGNATURE-----

--M3ixGbs6cpxcT1XHlVgIucud5P4hN5WcC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
