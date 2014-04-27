Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0DC6B003A
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 08:25:59 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so3999269eei.19
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 05:25:58 -0700 (PDT)
Received: from hygieia.santi-shop.eu (hygieia.santi-shop.eu. [78.46.175.2])
        by mx.google.com with ESMTPS id n46si19486044eeo.7.2014.04.27.05.25.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Apr 2014 05:25:57 -0700 (PDT)
Date: Sun, 27 Apr 2014 14:25:23 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: On a 3.14.1 system dirty count goes negative
Message-ID: <20140427142523.402d6b0f@neptune.home>
In-Reply-To: <20140427130651.07839e7f@neptune.home>
References: <20140427130651.07839e7f@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

The previous time I've seen it was on 3.13.6, 3 weeks ago,
I'm now on 3.14.1.

Setting /proc/sys/vm/dirty_bytes to very high number (around
18446744073709550284) but still smaller than (uint64)-1 gets
things running shortly/partially though.

System is single-CPU, CONFIG_SMP=3Dn, which might be important detail.

On Sun, 27 April 2014 Bruno Pr=C3=A9mont wrote:
> On a 3.14 system (KVM virtual machine 512MB RAM, x86_64) I'm seeing
> /proc/meminfo/Dirty getting extreemly large (u64 going "nevative").
>=20
> Note, this is not the first time I'm seeing it.
>=20
> The system is not doing too much but has a rather small amount of
> memory.
>=20
> MemTotal:         508512 kB
> MemFree:           23076 kB
> MemAvailable:     282092 kB
> Buffers:               0 kB
> Cached:           194548 kB
> SwapCached:         1500 kB
> Active:           168060 kB
> Inactive:         203080 kB
> Active(anon):      82300 kB
> Inactive(anon):    95992 kB
> Active(file):      85760 kB
> Inactive(file):   107088 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> SwapTotal:        524284 kB
> SwapFree:         515820 kB
> Dirty:          18446744073709550284 kB
> Writeback:             4 kB
> AnonPages:        175600 kB
> Mapped:            28784 kB
> Shmem:              1700 kB
> Slab:              92244 kB
> SReclaimable:      76812 kB
> SUnreclaim:        15432 kB
> KernelStack:        1128 kB
> PageTables:         5588 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:      778540 kB
> Committed_AS:    1036592 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:        4440 kB
> VmallocChunk:   34359711231 kB
> AnonHugePages:         0 kB
> DirectMap4k:       10228 kB
> DirectMap2M:      514048 kB
>=20
> Some tasks end up being stuck in balance_dirty_pages_ratelimited()
> because of this.
>=20
> I have no idea what triggers Dirty to go mad but it happens.
> It might be facilitated by some heavier IO (rsync of some data)
> while rrdcached (rrdtool) is touching RRDs or writing its data log.
> rrdcached is the one getting stuck in balance_dirty_pages_ratelimited().
>=20
> Is there a way to get the system rolling again (making
> dirty pages temporarily unlimited) or a way to determine why/when
> Dirty goes negative and possibly get a hint on the trigger?
>=20
> Thanks,
> Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
