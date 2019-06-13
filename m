Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0ABA1C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 03:36:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CED3120866
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 03:36:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CED3120866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52E8A6B0007; Wed, 12 Jun 2019 23:36:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DF476B000C; Wed, 12 Jun 2019 23:36:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CE1A6B0010; Wed, 12 Jun 2019 23:36:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 079B86B0007
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 23:36:55 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q2so11064841plr.19
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 20:36:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:to:cc:subject:references:in-reply-to:mime-version
         :content-transfer-encoding:content-disposition;
        bh=MweLbB9ZssUDSIR7gQX64E9C1EE/FRQrXHCHqGFo3UQ=;
        b=lr6N2r4aE++tnY5YGxW8q8W1Vyo2BOpre9KtzUW9z083oj4u73JT8MvmLUOny3tuGx
         XjiwmsHTfHNmbcAr9oEddQET+PBjbcZzJPVQUjJ1ywucev84kX7cq43V2i8x2YLA0Q9u
         gufDGyxMMOqNX/L/Fi9O04hMmqgiUmjJeLQB74F6WP8BwZXOiflWHqyCfSPOYEbr/LUN
         D9xjrxIyWNlZQZhWcM/vQNyr7aBw5uUKRaVjukA2u2TYDeIppU61wFr45eXXaaTx0YSl
         TPk/wSCr54cNDAwc/guc+UlIIXM6EDzwR7Ed8knbQOx6so5N/M+oapFbkja+bl+ANI7+
         Pi8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ghe@suse.com designates 137.65.248.33 as permitted sender) smtp.mailfrom=ghe@suse.com
X-Gm-Message-State: APjAAAXC+W6N/r1kP5HoYq9uEU7J/Thoc3tzjL1Wx6Hzjealv/aq3DWD
	meWDIlcKbZ18el2vCn/2YrEk5Cb4Iyb1yxAkPmfqKUCFSZ7bAuhyddfEaBV7czIZ2fyiOO8Ivvw
	oklFGG77VZRVWjU+EvocQu4B2iIL/cbeFePy15RXB6eB1Tj9O87PgDpbFFJhmEwdcaQ==
X-Received: by 2002:a17:90a:5887:: with SMTP id j7mr2559090pji.136.1560397014703;
        Wed, 12 Jun 2019 20:36:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxr2vVnmqGQMrorU+PL1fnOXe0peXFC6wKa4AMxNOiViCdgjrUvfviCeOxXAhQGhwhGQzuH
X-Received: by 2002:a17:90a:5887:: with SMTP id j7mr2559021pji.136.1560397013947;
        Wed, 12 Jun 2019 20:36:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560397013; cv=none;
        d=google.com; s=arc-20160816;
        b=oeOV73UfYmi92w2WRSkNfbBOsshTXKkH0TZCr9sr6eqU677sMmU85BeBD5htUmXGq1
         ZuzjkaiiePcSLCJ0cm1EHK19eYuqrlRtEqZtWgYQ3oHbhIMNgrsheFiwlLUqi5+xstRq
         6GvHnZSNdpppCtLbN+mss+5phRNrtXLdYgpV/tancGA38SwWgDmOJbP25lI8ejIN6yDK
         w5fhaUtlpFlvMNk/+KsL9rXiCv0XuzDk52xp5W/a/CPytCK++mdNgYKrzNC6kPpeGDNU
         FO93CE46APjQ4ptp40xNOdNVLEzM3FSI2WFhH8bRsCAJ7VRqs8aWTxw/l9oaqia7feGX
         N+RA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:content-transfer-encoding:mime-version
         :in-reply-to:references:subject:cc:to:from:date:message-id;
        bh=MweLbB9ZssUDSIR7gQX64E9C1EE/FRQrXHCHqGFo3UQ=;
        b=QJyO8y+Hn41fxKTLJPK1OEhhedUrWLnsd5/V3FhdW03CYOz0ZCJOmerBuDlWtsy7je
         j3U1HIw1o+WVWvNc+21vLujBYbHN7lPLOSc9tnUH0/R0y/MBmvOAYIk8gufsc301MHf9
         EzHf4z9jzPPPPKTOnuv/4Vxjcd8tDaMHnUhj8238bjT0owribYiwdKYPNUAt3xh5rqRP
         LERa9UkGlOMdMvuByyX3hpBc9Eoe8Z0zyZXlmSvNyq1iAPVHCQTLse1a3amO/BO4Cl4I
         /VZhtOa742rvGqcjj3jwqVIAZcvFfUYmGBfFrD+svjjsyZv/Mjo1srLzDwCwUmAF/juW
         S6nA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ghe@suse.com designates 137.65.248.33 as permitted sender) smtp.mailfrom=ghe@suse.com
Received: from prv1-mh.provo.novell.com (prv1-mh.provo.novell.com. [137.65.248.33])
        by mx.google.com with ESMTPS id e67si1547539pgc.11.2019.06.12.20.36.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 20:36:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of ghe@suse.com designates 137.65.248.33 as permitted sender) client-ip=137.65.248.33;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ghe@suse.com designates 137.65.248.33 as permitted sender) smtp.mailfrom=ghe@suse.com
Received: from INET-PRV1-MTA by prv1-mh.provo.novell.com
	with Novell_GroupWise; Wed, 12 Jun 2019 21:36:53 -0600
Message-Id: <5D01C4CD020000F90006C06A@prv1-mh.provo.novell.com>
X-Mailer: Novell GroupWise Internet Agent 18.1.1 
Date: Wed, 12 Jun 2019 21:36:45 -0600
From: "Gang He" <ghe@suse.com>
To: "Randy Dunlap" <rdunlap@infradead.org>,<akpm@linux-foundation.org>
Cc: <sfr@canb.auug.org.au>,<broonie@kernel.org>, <linux-mm@kvack.org>,
 "Joseph Qi" <joseph.qi@linux.alibaba.com>,
 <ocfs2-devel@oss.oracle.com>, <mhocko@suse.cz>,
 <linux-fsdevel@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-next@vger.kernel.org>, <mm-commits@vger.kernel.org>
Subject: Re: [Ocfs2-devel] mmotm 2019-06-11-16-59 uploaded (ocfs2)
References: <20190611235956.4FZF6%akpm@linux-foundation.org>
 <492b4bcc-4760-7cbb-7083-9f22e7ab4b82@infradead.org>
 <20190612181813.48ad05832e05f767e7116d7b@linux-foundation.org>
In-Reply-To: <20190612181813.48ad05832e05f767e7116d7b@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Randy and Andrew,

>>> On 6/13/2019 at  9:18 am, in message
<20190612181813.48ad05832e05f767e7116d7b@linux-foundation.org>, Andrew =
Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 12 Jun 2019 07:15:30 -0700 Randy Dunlap <rdunlap@infradead.org> =
wrote:
>=20
>> On 6/11/19 4:59 PM, akpm@linux-foundation.org wrote:
>> > The mm-of-the-moment snapshot 2019-06-11-16-59 has been uploaded to
>> >=20
>> >   =20
> https://urldefense.proofpoint.com/v2/url?u=3Dhttp-3A__www.ozlabs.org_-7Ea=
kpm_=20
> mmotm_&d=3DDwICAg&c=3DRoP1YumCXCgaWHvlZYR8PZh8Bv7qIrMUB65eapI_JnE&r=3DC7g=
Ad4uDxlAvTdc0
> vmU6X8CMk6L2iDY8-HD0qT6Fo7Y&m=3DzWoF0Bft4OzQeAaZXMGI56DN7p9MjLynOay4PZYAl=
hQ&s=3DvYme
> DBOk3Nv08-ZA7IweIdaUk094Ldvmgzc20fjjzDs&e=3D
>> >=20
>> > mmotm-readme.txt says
>> >=20
>> > README for mm-of-the-moment:
>> >=20
>> >=20
> https://urldefense.proofpoint.com/v2/url?u=3Dhttp-3A__www.ozlabs.org_-7Ea=
kpm_mmo=20
> tm_&d=3DDwICAg&c=3DRoP1YumCXCgaWHvlZYR8PZh8Bv7qIrMUB65eapI_JnE&r=3DC7gAd4=
uDxlAvTdc0vmU
> 6X8CMk6L2iDY8-HD0qT6Fo7Y&m=3DzWoF0Bft4OzQeAaZXMGI56DN7p9MjLynOay4PZYAlhQ&=
s=3DvYmeDBO
> k3Nv08-ZA7IweIdaUk094Ldvmgzc20fjjzDs&e=3D
>> >=20
>> > This is a snapshot of my -mm patch queue.  Uploaded at random =
hopefully
>> > more than once a week.
>>=20
>>=20
>> on i386:
>>=20
>> ld: fs/ocfs2/dlmglue.o: in function `ocfs2_dlm_seq_show':
>> dlmglue.c:(.text+0x46e4): undefined reference to `__udivdi3'
>=20
> Thanks.  This, I guess:
>=20
> --- a/fs/ocfs2/dlmglue.c~ocfs2-add-locking-filter-debugfs-file-fix
> +++ a/fs/ocfs2/dlmglue.c
> @@ -3115,7 +3115,7 @@ static int ocfs2_dlm_seq_show(struct seq
>  		 * otherwise, only dump the last N seconds active lock
>  		 * resources.
>  		 */
> -		if ((now - last) / 1000000 > dlm_debug->d_filter_secs)
> +		if (div_u64(now - last, 1000000) > dlm_debug->d_filter_secs=
)
>  			return 0;
>  	}
>  #endif
>=20
> review and test, please?
Thank for this fix, the change is OK for my testing on x86_64.

Thanks
Gang

>=20
> _______________________________________________
> Ocfs2-devel mailing list
> Ocfs2-devel@oss.oracle.com=20
> https://oss.oracle.com/mailman/listinfo/ocfs2-devel

