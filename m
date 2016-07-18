Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0666B025E
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 18:05:53 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id c124so674284ywd.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 15:05:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o13si11645203qkl.331.2016.07.18.15.05.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 15:05:52 -0700 (PDT)
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
 <20160715130458.GB21685@350D>
 <41b6ca51-1358-0fd7-b45a-dc29a1344865@gmail.com>
From: Doug Ledford <dledford@redhat.com>
Message-ID: <dc74346d-141b-d22c-72ac-de8f3ce5f766@redhat.com>
Date: Mon, 18 Jul 2016 18:05:31 -0400
MIME-Version: 1.0
In-Reply-To: <41b6ca51-1358-0fd7-b45a-dc29a1344865@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="F9jkiFT0bsWgPk4OVF6FuXMes50sEeJEW"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Topi Miettinen <toiwoton@gmail.com>, bsingharora@gmail.com
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Alexei Starovoitov <ast@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Markus Elfring <elfring@users.sourceforge.net>, "David S. Miller" <davem@davemloft.net>, Nicolas Dichtel <nicolas.dichtel@6wind.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Jiri Slaby <jslaby@suse.cz>, Cyrill Gorcunov <gorcunov@openvz.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Michael Kerrisk <mtk.manpages@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Marcus Gelderie <redmnic@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Joe Perches <joe@perches.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <ak@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Stas Sergeev <stsp@list.ru>, Amanieu d'Antras <amanieu@gmail.com>, Richard Weinberger <richard@nod.at>, Wang Xiaoqiang <wangxq10@lzu.edu.cn>, Helge Deller <deller@gmx.de>, Mateusz Guzik <mguzik@redhat.com>, Alex Thorlton <athorlton@sgi.com>, Ben Segall <bsegall@google.com>, John Stultz <john.stultz@linaro.org>, Rik van Riel <riel@redhat.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM) FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM)" <kvm@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:FILESYSTEMS (VFS and infrastructure)" <linux-fsdevel@vger.kernel.org>, "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>, "open list:BPF (Safe dynamic programs and tools)" <netdev@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--F9jkiFT0bsWgPk4OVF6FuXMes50sEeJEW
Content-Type: multipart/mixed; boundary="8Nu7KMlW20LvvH3vroJakcrp9lO3XsH14"
From: Doug Ledford <dledford@redhat.com>
To: Topi Miettinen <toiwoton@gmail.com>, bsingharora@gmail.com
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
 Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
 Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>,
 =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
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
 Richard Weinberger <richard@nod.at>, Wang Xiaoqiang <wangxq10@lzu.edu.cn>,
 Helge Deller <deller@gmx.de>, Mateusz Guzik <mguzik@redhat.com>,
 Alex Thorlton <athorlton@sgi.com>, Ben Segall <bsegall@google.com>,
 John Stultz <john.stultz@linaro.org>, Rik van Riel <riel@redhat.com>,
 Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>,
 Chen Gang <gang.chen.5i5j@gmail.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
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
Message-ID: <dc74346d-141b-d22c-72ac-de8f3ce5f766@redhat.com>
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
 <20160715130458.GB21685@350D>
 <41b6ca51-1358-0fd7-b45a-dc29a1344865@gmail.com>
In-Reply-To: <41b6ca51-1358-0fd7-b45a-dc29a1344865@gmail.com>

--8Nu7KMlW20LvvH3vroJakcrp9lO3XsH14
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 7/15/2016 12:35 PM, Topi Miettinen wrote:
> On 07/15/16 13:04, Balbir Singh wrote:
>> On Fri, Jul 15, 2016 at 01:35:47PM +0300, Topi Miettinen wrote:
>>> Hello,
>>>
>>> There are many basic ways to control processes, including capabilitie=
s,
>>> cgroups and resource limits. However, there are far fewer ways to fin=
d out
>>> useful values for the limits, except blind trial and error.
>>>
>>> This patch series attempts to fix that by giving at least a nice star=
ting
>>> point from the highwater mark values of the resources in question.
>>> I looked where each limit is checked and added a call to update the m=
ark
>>> nearby.
>>>
>>> Example run of program from Documentation/accounting/getdelauys.c:
>>>
>>> ./getdelays -R -p `pidof smartd`
>>> printing resource accounting
>>> RLIMIT_CPU=3D0
>>> RLIMIT_FSIZE=3D0
>>> RLIMIT_DATA=3D18198528
>>> RLIMIT_STACK=3D135168
>>> RLIMIT_CORE=3D0
>>> RLIMIT_RSS=3D0
>>> RLIMIT_NPROC=3D1
>>> RLIMIT_NOFILE=3D55
>>> RLIMIT_MEMLOCK=3D0
>>> RLIMIT_AS=3D130879488
>>> RLIMIT_LOCKS=3D0
>>> RLIMIT_SIGPENDING=3D0
>>> RLIMIT_MSGQUEUE=3D0
>>> RLIMIT_NICE=3D0
>>> RLIMIT_RTPRIO=3D0
>>> RLIMIT_RTTIME=3D0
>>>
>>> ./getdelays -R -C /sys/fs/cgroup/systemd/system.slice/smartd.service/=

>>> printing resource accounting
>>> sleeping 1, blocked 0, running 0, stopped 0, uninterruptible 0
>>> RLIMIT_CPU=3D0
>>> RLIMIT_FSIZE=3D0
>>> RLIMIT_DATA=3D18198528
>>> RLIMIT_STACK=3D135168
>>> RLIMIT_CORE=3D0
>>> RLIMIT_RSS=3D0
>>> RLIMIT_NPROC=3D1
>>> RLIMIT_NOFILE=3D55
>>> RLIMIT_MEMLOCK=3D0
>>> RLIMIT_AS=3D130879488
>>> RLIMIT_LOCKS=3D0
>>> RLIMIT_SIGPENDING=3D0
>>> RLIMIT_MSGQUEUE=3D0
>>> RLIMIT_NICE=3D0
>>> RLIMIT_RTPRIO=3D0
>>> RLIMIT_RTTIME=3D0
>>
>> Does this mean that rlimit_data and rlimit_stack should be set to the
>> values as specified by the data above?
>=20
> My plan is that either system administrator, distro maintainer or even
> upstream developer can get reasonable values for the limits. They may
> still be wrong, but things would be better than without any help to
> configure the system.

This is not necessarily true.  It seems like there is a disconnect
between what these various values are for and what you are positioning
them as.  Most of these limits are meant to protect the system from
resource starvation crashes.  They aren't meant to be any sort of double
check on a specific application.  The vast majority of applications can
have bugs, leak resources, and do all sorts of other bad things and
still not hit these limits.  A program that leaks a file handle an hour
but only normally has 50 handles in use would take 950 hours of constant
leaking before these limits would kick in to bring the program under
control.  That's over a month.  What's more though, the kernel couldn't
really care less that a single application leaked files until it got to
1000 open.  The real point of the limit on file handles (since they are
cheap) is just not to let the system get brought down.  Someone could
maliciously fire up 1000 processes, and they could all attempt to open
up as many files as possible in order to drown the system in open
inodes.  The combination of the limit on maximum user processes and
maximum files per process are intended to prevent this.  They are not
intended to prevent a single, properly running application from
operating.  In fact, there are very few applications that are likely to
break the 1000 file per process limit.  It is outrageously high for most
applications.  They will leak files and do all sorts of bad things
without this ever stopping them.  But it does stop malicious programs.
And the process limit stops malicious users too.  The max locked memory
is used by almost no processes, and for the very few that use it, the
default is more than enough.  The major exception is the RDMA stack,
which uses it so much that we just disable it on large systems because
it's impossible to predict how much we'll need and we don't want a job
to get killed because it couldn't get the memory it needs for buffers.
The limit on POSIX message queues is another one where it's more than
enough for most applications which don't use this feature at all, and
the few systems that use this feature adjust the limit to something sane
on their system (we can't make the default sane for these special
systems or else it becomes an avenue for Denial of Service attack, so
the default must stay low and servers that make extensive use of this
feature must up their limit on a case by case basis).

>>
>> Do we expect a smart user space daemon to then tweak the RLIMIT values=
?
>=20
> Someone could write an autotuning daemon that checks if the system has
> changed (for example due to upgrade) and then run some tests to
> reconfigure the system. But the limits are a bit too fragile, or rather=
,
> applications can't handle failure, so I don't know if that would really=

> work.

This misses the point of most of these limits.  They aren't there to
keep normal processes and normal users in check.  They are there to stop
runaway use.  This runaway situation might be accidental, or it might be
a nefarious users.  They are generally set exceedingly high for those
things every application uses, and fairly low for those things that
almost no application uses but which could be abused by the nefarious
user crowd.

Moreover, for a large percentage of applications, the highwatermark is a
source of great trickery.  For instance, if you have a web server that
is hosting web pages written in python, and therefore are using
mod_python in the httpd server (assuming apache here), then your
highwatermark will never be a reliable, stable thing.  If you get 1000
web requests in a minute, all utilizing the mod_python resource in the
web server, and you don't have your httpd configured to restart after
every few hundred requests handled, then mod_python in your httpd
process will grow seemingly without limit.  It will consume tons of
memory.  And the only limit on how much memory it will consume is
determined by how many web requests it handles in between its garbage
collection intervals * how much memory it allocates per request.  If you
don't happen to catch the absolute highest amount while you are
gathering your watermarks, then when you actually switch the system to
enforcing the limits you learned from all your highwatermarks (you are
planning on doing that aren't you?....I didn't see a copy of the patch
1/14, so I don't know if this infrastructure ever goes back to enforcing
the limits or not, but I would assume so, what point is there in
learning what the limits should be if you then never turn around and
enforce them?), load spikes will cause random program failures.

Really, this looks like a solution in search of a problem.  Right now,
the limits are set where they are because they do two things:

1) Stay out of the way of the vast majority of applications.  Those
applications that get tripped up by the defaults (like RDMA applications
getting stopped by memlock settings) have setup guides that spell out
which limits need changed and hints on what to change them too.

2) Stop nefarious users or errant applications from a total runaway
situation on a machine.

If your applications run without fail unless they have already failed,
and the whole machine doesn't go down with your failed application, then
the limits are working as designed.  If your typical machine
configuration includes 256GB of RAM, then you could probably stand to
increase some of the limits safely if you wanted to.  But unless you
have applications getting killed because of these limits, why would you?

Right now, I'm inclined to NAK the patch set.  I've only seen patch 9/14
since you didn't Cc: everyone on the patch 1/14 that added the
infrastructure.  But, as I mentioned in another email, I think this can
be accomplished via a systemtap script instead so we keep the clutter
out of the kernel.  And more importantly, these patches seem to be
thinking about these limits as though they are supposed to be some sort
of tight fitting container around applications that catch an errant
application as soon as it steps out of bounds.  Nothing could be further
from the truth, and if we actually implemented something of that sort,
programs susceptible to high resource usage during load spikes would
suddenly start failing on a frequent basis.  The proof that these limits
are working is given by the fact that we rarely hear from users about
their programs being killed for resource consumption, and yet we also
don't hear from users about their systems going down due to runaway
applications.  From what I can tell from these patches, I would suspect
complaints from one of those two issues to increase once these patches
are in place and put in use, and that doesn't seem like a good thing.

--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--8Nu7KMlW20LvvH3vroJakcrp9lO3XsH14--

--F9jkiFT0bsWgPk4OVF6FuXMes50sEeJEW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXjVKsAAoJELgmozMOVy/d8OkP/29+ozde5uLxvxBQIOOLfOwQ
esN5JxLREIBpDmtKgYGZAKj/fgiOCGY24AL7N+f6aauTa7VLi8Vc7pHiDYjRFRk3
AXKYCW5hnApVRygKqRxkpuq5r/nze5B87icZ93BZNrPEkEhsKZT2mshHIa0EiBLT
CLfSrfVbIztHujUK7pDrhtK80E9VhK3RIAVX7SqQLBgYFpP6NQglR342T8WBXsTI
PdjeYQnxKAzDC7iyUVsWSYf+7DlUSK4Kw7mWf7mAQekdfaRQzt7tlKGYMSGmvHNm
7a4CcdQe/rPHVSAshYfVBv2SUK/OFmbufzNxDPbWA+vm/yCcwfyaFNm/gg/zOdMs
K1Gru6JKg9CReCn7L9iXVkrjZy9ZoXeSZZjdWini+NOO/w+VPfWYspofA1cWa0Yk
6EYaM7VGrG0F9xXb1DMt1elQ636bajvB+AErkTxI7kKHmm082MomCIyjNVh08arU
kxexdC5SD0fdHFIQwH9w6Hbt8N+lr21fQsAc1BTUPwQaeUC+I+jJywcq4TSioALL
ahC0boOVxn45Uoq7SnrfaGcFw6HWNw96EmqC1YtG3sIIKNuxTFsZECdsqz6Dlq8B
bX5b3vgZEzFUunbNfqGUGR+6tQislHNYZXm9dtuit7xMWwY4gVlNSWm7BzkPsAV6
P8fiVsdUPEvoigV3LOTG
=JZfy
-----END PGP SIGNATURE-----

--F9jkiFT0bsWgPk4OVF6FuXMes50sEeJEW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
