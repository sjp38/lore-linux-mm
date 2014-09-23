Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 841296B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 12:20:04 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id em10so5205449wid.17
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 09:20:04 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2001:468:c80:2105:0:24d:7091:8b9c])
        by mx.google.com with ESMTPS id ka3si15644009wjc.127.2014.09.23.09.20.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 09:20:03 -0700 (PDT)
Subject: Re: [PATCH] mm, debug: mm-introduce-vm_bug_on_mm-fix-fix.patch
In-Reply-To: Your message of "Tue, 23 Sep 2014 13:28:48 +0200."
             <20140923112848.GA10046@dhcp22.suse.cz>
From: Valdis.Kletnieks@vt.edu
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org> <1411464279-20158-1-git-send-email-mhocko@suse.cz>
            <20140923112848.GA10046@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1411489189_2175P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Sep 2014 12:19:49 -0400
Message-ID: <83907.1411489189@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, Sasha Levin <sasha.levin@oracle.com>

--==_Exmh_1411489189_2175P
Content-Type: text/plain; charset=us-ascii

On Tue, 23 Sep 2014 13:28:48 +0200, Michal Hocko said:
> And there is another one hitting during randconfig. The patch makes my
> eyes bleed

Amen.  But I'm not seeing a better fix either.

>  #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
> -		"tlb_flush_pending %d\n",
> +		"tlb_flush_pending %d\n"
>  #endif
> -		mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
> +		, mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,

I'm surprised that checkpatch doesn't explode on this.  And I'm starting
a pool on how soon somebody submits a patch to "fix" this. :)

--==_Exmh_1411489189_2175P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVCGdpQdmEQWDXROgAQLLKBAAiTSdExIo2aogwb191B7h7hkYPyPVu8ne
lyHn0dfT7JDVht3nsQBmDHn48qL/h4d+GvU0priCoHlvXG+17p5asW/bcaOttavH
xPSagNrH7sCUGhZyupe9n5ZFfw4Mer41uA9H4cFqMOVJCoSJyCMvCPB9ilKWDOZl
dTbzN/XyRVhFR6nHoecXGWlAsHFWi2zstPPYi98fmM9VqZQ/025wpr5Fb0Ffdphr
csIwovxR2blTVQpGUSZhPRYbGaPPL6S4JJ8waC7IDmAWqdyvj7vY3Z5L5n44vu+d
QeRUsCD30w0B14QdBO2fFl2LE2LppsEjjmQ2RrGoRpB9MSKhXdK2wF4uL6xzLIWL
CGYoPkR6mvPmDX5rOJMN7AWx5wTcB6jhp1xnDyhK3IlfzurOmZaqi/YuzHqXUwkV
DQL1VYz1FTBd1yRyqY6OCRcjaZHopijNiyAvrSwvcpylELDCLqg6Sm+6zQG8Nmw4
CFLi6fRhYZUr0ypQQwsyk9KHQBWMkOi+gYGalM2ahD/TnfeLx+T2FA79Tb2rTW5w
jtoPo5nryghgWSeF2oaWE13iJNEjyZUb6PjWcUn+lhbr+6lcCr0FCCXapSAlR80A
++W/jsSBDNPbNNskbKzuvJxN+hxDzYWxNJLlhCqJeu5yydgS8Is5jXOa7N3dwKS3
Esg0LBXwHp4=
=2FOW
-----END PGP SIGNATURE-----

--==_Exmh_1411489189_2175P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
