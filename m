Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCABEC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:33:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 965DF20820
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:33:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 965DF20820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ucw.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B7B86B0006; Tue, 11 Jun 2019 06:33:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1685A6B0007; Tue, 11 Jun 2019 06:33:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 058EE6B0008; Tue, 11 Jun 2019 06:33:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC1076B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 06:33:18 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id 20so422214wma.2
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 03:33:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kV96tPAL7kYj88H4EhLrLgx83C/B1Q/iCV+KW7K22qI=;
        b=klU37S8XJvrt8N/dJoaGExnIljsIEkk24AqQEgU9XeClBoCmOIz0YD9hha1eXxa1cw
         SjjtnSVTX8C/L/5/11W1P+QUaw7qwBxvHyR2rdGOAVljdkeOhyJKfYGjswD22kvhMbIr
         Rn7uYNHC6GPeBGwR0z4NJGGmdLgJByGA3BLgmEvd0Fx6siDVSE05gKgnbSC/xn4voajl
         Hp/QSrddpbagtuVUng2Np4t935uXtMG6eAqN5uU9A3jqmNiHJKMXo/jzeJgp8DuN5abs
         oMb60UqaWpwq7CNtyOeBC1YLEv9Z2ueDN0u+nxHQkUkBJL9WQQIuxAVRmqacs4k+oTSn
         WB3g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
X-Gm-Message-State: APjAAAUye4oNfXx932CGIMUQQGKUlLiuFUSU24w/fMlVxf7Bf13BE4NW
	TUWK63CsOz8SD9bXDR9iA34x/WQTUrbjwb/yUUvHD55n4eR3NHiXNnkSaJ1OsceuAaRAGlmmIoV
	JUkC7oKeBjI2XvPKHkY6zv98Zj5cUFeeR/qErZIyjwdeCkzrOMBx4GjM+m0O19FA=
X-Received: by 2002:a1c:63d7:: with SMTP id x206mr17497191wmb.19.1560249198174;
        Tue, 11 Jun 2019 03:33:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSlCSCdSNABH3HbeAXaSrpxI4tVFy9Kxv1wOiwFjmQ/q49p8yn77H7Ehm/P3N5SyWqyj+F
X-Received: by 2002:a1c:63d7:: with SMTP id x206mr17497102wmb.19.1560249197138;
        Tue, 11 Jun 2019 03:33:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560249197; cv=none;
        d=google.com; s=arc-20160816;
        b=B16A+Q8TXopsCJNTYdObXaHhCmi8qxETlfIgO9W57lpohji0DuG3nSZpOvzkZwHlK2
         8ZlHnmUCJoG8N4PnhukzpEeZe2j9lI5ki6+9WcpsZ9al0MU+nbnYCeE4VzuuL6nnVb1w
         zBMt/AqN3yo4hJAlF+PcYLZ6hB5SmpCC1bvrlqhjVrD70OQgDbMIogi6DV9DvE2mIqHb
         q49tGWvRCBMOPHuUFIvb0cN21UDaGuRzhNEsxM5FGTGZ3GExU8JucHi4XGYvn/vAlGBU
         QGjeme/iLC32vXB5m2853apQYuYYMQV0jafXBY/QCSXSZ5Z69pKDFbn+UnyCOGxf9/xM
         G4WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kV96tPAL7kYj88H4EhLrLgx83C/B1Q/iCV+KW7K22qI=;
        b=nYMv1n9FegSBmCt6X2RTn/HkEzX2J57f2flhGmVyvPdY3wAIaH9qrB6JcCaCCeJDS/
         2W0C1kU7bQM9XDywjcDw3z2WmTnQfu+r6xa5SaEdILmistL1HDSwm/Tb3NnwiV3bPltg
         f37wjmF2bLHVc4Pm0VFzoRJULJNn9Ce/uMZQgridc8VhJPMoc7Qo2a2G8CjCDMNv+DJi
         8BwfafMyfedukiwoIoOJQd7Deayx7dJPaSfjnclcPLpBuTHBtSMud+F/nfw8ytkbNxt6
         3mAIZNHUbWtb4LczCUofEzIMow2ugINueqMqzjx4eghEzzYzzVtLuxEPUPBrNu4jLBX3
         gjOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id v1si1884327wrw.353.2019.06.11.03.33.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 03:33:17 -0700 (PDT)
Received-SPF: neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) client-ip=195.113.26.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: by atrey.karlin.mff.cuni.cz (Postfix, from userid 512)
	id 21FC68023C; Tue, 11 Jun 2019 12:33:06 +0200 (CEST)
Date: Tue, 11 Jun 2019 12:33:16 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
Message-ID: <20190611103316.GA20775@amd>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
 <20190606200926.4029-4-yu-cheng.yu@intel.com>
 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
 <20190608205218.GA2359@xo-6d-61-c0.localdomain>
 <e1543e7beb0eb55d6febcd847ccab9b219e60338.camel@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="AhhlLboLdkugWU4S"
Content-Disposition: inline
In-Reply-To: <e1543e7beb0eb55d6febcd847ccab9b219e60338.camel@intel.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2019-06-10 08:47:45, Yu-cheng Yu wrote:
> On Sat, 2019-06-08 at 22:52 +0200, Pavel Machek wrote:
> > Hi!
> >=20
> > > > I've no idea what the kernel should do; since you failed to answer =
the
> > > > question what happens when you point this to garbage.
> > > >=20
> > > > Does it then fault or what?
> > >=20
> > > Yeah, I think you'll fault with a rather mysterious CR2 value since
> > > you'll go look at the instruction that faulted and not see any
> > > references to the CR2 value.
> > >=20
> > > I think this new MSR probably needs to get included in oops output wh=
en
> > > CET is enabled.
> > >=20
> > > Why don't we require that a VMA be in place for the entire bitmap?
> > > Don't we need a "get" prctl function too in case something like a JIT=
 is
> > > running and needs to find the location of this bitmap to set bits its=
elf?
> > >=20
> > > Or, do we just go whole-hog and have the kernel manage the bitmap
> > > itself. Our interface here could be:
> > >=20
> > > 	prctl(PR_MARK_CODE_AS_LEGACY, start, size);
> > >=20
> > > and then have the kernel allocate and set the bitmap for those code
> > > locations.
> >=20
> > For the record, that sounds like a better interface than userspace know=
ing
> > about the bitmap formats...
> > 									Pavel
>=20
> Initially we implemented the bitmap that way.  To manage the bitmap, ever=
y time
> the application issues a syscall for a .so it loads, and the kernel does
> copy_from_user() & copy_to_user() (or similar things).  If a system has a=
 few
> legacy .so files and every application does the same, it can take a long =
time to
> boot up.

Loading .so is already many syscalls, I'd not expect measurable
performance there. Are you sure?
								Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--AhhlLboLdkugWU4S
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlz/g2wACgkQMOfwapXb+vIj7QCfRkp2CAAYHfFjIjZpoiuF3QSp
XOcAn2kbcxPiUdvqncAD5H23uN2WhHP1
=j3lF
-----END PGP SIGNATURE-----

--AhhlLboLdkugWU4S--

