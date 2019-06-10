Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 905D0C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 15:27:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31E23206C3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 15:27:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31E23206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86DD86B026A; Mon, 10 Jun 2019 11:27:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F8296B026B; Mon, 10 Jun 2019 11:27:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 697B66B026C; Mon, 10 Jun 2019 11:27:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 330DB6B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 11:27:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y5so7407700pfb.20
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 08:27:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:in-reply-to:references:user-agent:mime-version
         :message-id;
        bh=UQxsXAuRk+rUs4uYlbPrS3cVObWPg7oF06ziDpBRefw=;
        b=NdUgnwezMD164xnKrtfJJ+vnOFXKT22LMHO4KH3yVLqnnEDhQgfYLpscrQBpj/7Qxr
         ZCG0M7FL6MC2AFT+SJKdtM/tNAA5Ha9BVvnegtxu+taJQQEP+Stj7QtIoUB7iK/kBFde
         Fv1/lEWmkVETmaRE5ideq3wlhOMHd4Zasl9HI0DK/ewr93L8/Xvoe1rHaCoj3zhnNqQI
         tOehl8DSRpDgtqH02YRoHu6XZCcnsi77LOY7dcwGzytR/LwSKolykxsRzYznoTug1V8H
         Smf5M8RbZA228NzORM10Cw2GgT9ynFrleRXHiQe6lkKPQTLJnPS7R/1A78KqYi+eXTJJ
         F7TA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=leonardo@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWA+0DsvnYLzH1gyGe6c5raJAgTzWNfVafZsPnxq6M4/26OIbhi
	0DJ8rmlgVaTPcuttCE+pcILHBwxANdW/J4pNIpxORA8kbe1eqeNRhKbUIXMXrW/VuZ8AaSARg0m
	s1qMVMrftOWk2R/FNpxVx3FqdIW/v9ajOSdk9ebGd0R2mAgLnQZfCxxjkrAON2bho7A==
X-Received: by 2002:a17:90a:dd45:: with SMTP id u5mr1179494pjv.109.1560180447673;
        Mon, 10 Jun 2019 08:27:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx53+QKx9dnCEJEgqbmmx9rtRyCLXDTTFiZ4Uhlw2CfRRDO5v08Ess01XulH7O3Xvde+Gsk
X-Received: by 2002:a17:90a:dd45:: with SMTP id u5mr1179417pjv.109.1560180446454;
        Mon, 10 Jun 2019 08:27:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560180446; cv=none;
        d=google.com; s=arc-20160816;
        b=GIOhhXw7gT/5ChDUcYj5WObGw51skLsWtqN8eS3eDhgCZhLaVCXftPhCJAW9bM5ZWn
         uC5q3tPBcgB+b/Ok2GrihQXP3g7CRBuDkOImT+d7PJfOokhYhgwyHjHyXhIbdvg7Pp7v
         55YdyzAXnmpyI4WWqKNFkzAQqJAU0jHlvB8nKQJppx0zue2EW7XL5xXyvcrV7WeJRQdX
         +YVSVbP/4k9Wli1l75/+O5WXIbI523xWXqrxW16g0qOuYAsPqlr5kS+vcT/YpHbyc9FS
         nVc4+cylZpGKX3Z93UXNGH0OJYUs5XKY1LIuSedVzUoM6Q+fo4IsSFzqKYzenz3n3sMn
         XlPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:user-agent:references:in-reply-to:date:cc
         :to:from:subject;
        bh=UQxsXAuRk+rUs4uYlbPrS3cVObWPg7oF06ziDpBRefw=;
        b=IoCJgtfV8G2byfJpu+cplAx5u7p56lmlsfgWLQje/l+1c7JK+pejWsyx923HDdIKtm
         SXNKyKKXd0BDLJ7gc9sCpNCPgaqGPWK/nzMCEKfuPRruk32D0CJaIHgb+bMfhtUpPZzR
         UHAAemAh+RsykRHzBAK7PSwg++gKAv/dRKYnMguk6JQL4YqIDKXZakilFnU9h4Nd0e0B
         qcR0ueF6w8zYhbZJaDIZjv4X0xiW20Bfi/UqO+PdFIWddElt39C9AkBtF9SNmK4KcfFi
         0C45HmUisSUKitZRHR2Fd8O4YtbH8F+RE7DwBpxwTrTxMyQyjtBKqI/iYLDUS3h5Ha5g
         xO8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=leonardo@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h11si2385605pls.374.2019.06.10.08.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 08:27:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=leonardo@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5AFRM0E003349
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 11:27:25 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t1rynjqk2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 11:27:25 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <leonardo@linux.ibm.com>;
	Mon, 10 Jun 2019 16:27:23 +0100
Received: from b01cxnp22036.gho.pok.ibm.com (9.57.198.26)
	by e12.ny.us.ibm.com (146.89.104.199) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 10 Jun 2019 16:27:16 +0100
Received: from b01ledav004.gho.pok.ibm.com (b01ledav004.gho.pok.ibm.com [9.57.199.109])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5AFREZv35914148
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 10 Jun 2019 15:27:14 GMT
Received: from b01ledav004.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8F287112061;
	Mon, 10 Jun 2019 15:27:14 +0000 (GMT)
Received: from b01ledav004.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 834D3112062;
	Mon, 10 Jun 2019 15:27:07 +0000 (GMT)
Received: from LeoBras (unknown [9.80.212.30])
	by b01ledav004.gho.pok.ibm.com (Postfix) with ESMTP;
	Mon, 10 Jun 2019 15:27:07 +0000 (GMT)
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
From: Leonardo Bras <leonardo@linux.ibm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>,
        Christophe Leroy
 <christophe.leroy@c-s.fr>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>,
        linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org,
        Peter Zijlstra
 <peterz@infradead.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Dave
 Hansen <dave.hansen@linux.intel.com>,
        Heiko Carstens
 <heiko.carstens@de.ibm.com>,
        Paul Mackerras <paulus@samba.org>,
        Matthew
 Wilcox <willy@infradead.org>, sparclinux@vger.kernel.org,
        linux-s390@vger.kernel.org,
        Yoshinori Sato <ysato@users.sourceforge.jp>, x86@kernel.org,
        Russell King <linux@armlinux.org.uk>,
        Will Deacon
 <will.deacon@arm.com>, Ingo Molnar <mingo@redhat.com>,
        Fenghua Yu
 <fenghua.yu@intel.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Andrey
 Konovalov <andreyknvl@google.com>,
        Andy Lutomirski <luto@kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>,
        Martin Schwidefsky
 <schwidefsky@de.ibm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>
Date: Mon, 10 Jun 2019 12:27:02 -0300
In-Reply-To: <97e9c9b3-89c8-d378-4730-841a900e6800@arm.com>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
	 <ec764ff4-f68a-fce5-ac1e-a4664e1123c7@c-s.fr>
	 <97e9c9b3-89c8-d378-4730-841a900e6800@arm.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-5Zy/vH+sEK4zQeyqr1da"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19061015-0060-0000-0000-0000034E9532
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011243; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01216003; UDB=6.00639329; IPR=6.00997102;
 MB=3.00027253; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-10 15:27:23
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061015-0061-0000-0000-000049B7F47B
Message-Id: <8dd6168592437378ff4a7c204e0f2962d002b44f.camel@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-10_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=628 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906100106
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-5Zy/vH+sEK4zQeyqr1da
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2019-06-10 at 08:09 +0530, Anshuman Khandual wrote:
> > > +    /*
> > > +     * To be potentially processing a kprobe fault and to be allowed
> > > +     * to call kprobe_running(), we have to be non-preemptible.
> > > +     */
> > > +    if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
> > > +        if (kprobe_running() && kprobe_fault_handler(regs, trap))
> >=20
> > don't need an 'if A if B', can do 'if A && B'
>=20
> Which will make it a very lengthy condition check.

Well, is there any problem line-breaking the if condition?

if (A && B && C &&
    D && E )

Also, if it's used only to decide the return value, maybe would be fine
to do somethink like that:

return (A && B && C &&
        D && E );=20

Regards,

--=-5Zy/vH+sEK4zQeyqr1da
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEMdeUgIzgjf6YmUyOlQYWtz9SttQFAlz+dsYACgkQlQYWtz9S
ttTfRQ/7BnCF2Sm8vpCKt6ji0Aq2vGhwsM6ISA+Vx72iI70yBg1jdV88yhko7lp4
xOwZejel20zp4V3f2xXCpyVnjbg0RNSBBHjkSsWJTHPQd+dVYqoLkR98Q8WrV1Q+
o0LxhoGGEpJwQanH1WL/P1t1crvBt4Htbg9wXfdbJGiFKDvsocC/fBuNkbijcGl2
JvLF8LFak6qojcDxLu4xvBIIrEuL60RklTTRwlZyKi3z4hfZUPLuUkpv4BYexDKU
mbJMxgJ/IgrCWmteuPXuVZHgK80UpvJUM6jacPRWdiIDQ0zG2NbJRh8o7WS4ZtaA
mShCl/Y72OZ9INtiP9ZTHItZyksARvwzFalnkyNkpdigr0FgLYy9tjYlD6ex6Z6W
qWrJSWPsUGDvcE5iy0tfRp/Vq03w1YNbofrg0eIo995y3VW8BM4rR72OrFMWeSuM
x7/4o4EvjYwVK9GTJWECK6wNH/+V3DUgMOJk9SFCde5Qdkg2i9Xpl9prxij8YMFc
AUDqw6hStj1Sb/XfJXIwpHflJsfTK2pozWISJInBkyxFnEIpNpQAHUPn1I1l26LQ
pDL47J1Wn/zM1EtAIgDOEATxWPyRqJN4nFniwAVhMslHB44MAS+XY3KPAr24zSM2
+t+VW/uhJw9igsLPPpyhzQa34M6O+tvw/pHV/IrJCm2vzNBdu9E=
=oA4R
-----END PGP SIGNATURE-----

--=-5Zy/vH+sEK4zQeyqr1da--

