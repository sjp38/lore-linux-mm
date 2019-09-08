Return-Path: <SRS0=7uET=XD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17774C4332F
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 15:38:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CF1B214DB
	for <linux-mm@archiver.kernel.org>; Sun,  8 Sep 2019 15:38:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CF1B214DB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD8316B0003; Sun,  8 Sep 2019 11:38:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D88196B0006; Sun,  8 Sep 2019 11:38:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9ED26B0007; Sun,  8 Sep 2019 11:38:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0037.hostedemail.com [216.40.44.37])
	by kanga.kvack.org (Postfix) with ESMTP id A7AB96B0003
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 11:38:39 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 56A5E824CA3F
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 15:38:39 +0000 (UTC)
X-FDA: 75912160758.08.plant78_1148b7abb0b04
X-HE-Tag: plant78_1148b7abb0b04
X-Filterd-Recvd-Size: 5211
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 15:38:38 +0000 (UTC)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x88FbmNN027376
	for <linux-mm@kvack.org>; Sun, 8 Sep 2019 11:38:37 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uvt2uvqs8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 08 Sep 2019 11:38:36 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zohar@linux.ibm.com>;
	Sun, 8 Sep 2019 16:38:33 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 8 Sep 2019 16:38:29 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x88FcSkX29950086
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 8 Sep 2019 15:38:29 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0277FA405E;
	Sun,  8 Sep 2019 15:38:28 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 21D7FA405F;
	Sun,  8 Sep 2019 15:38:27 +0000 (GMT)
Received: from localhost.localdomain (unknown [9.85.159.93])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Sun,  8 Sep 2019 15:38:26 +0000 (GMT)
Subject: Re: [PATCH 2/3] ima: update the file measurement on truncate
From: Mimi Zohar <zohar@linux.ibm.com>
To: Janne Karhunen <janne.karhunen@gmail.com>, linux-integrity@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-mm@kvack.org,
        viro@zeniv.linux.org.uk
Cc: Konsta Karsisto <konsta.karsisto@gmail.com>
Date: Sun, 08 Sep 2019 11:38:26 -0400
In-Reply-To: <20190902094540.12786-2-janne.karhunen@gmail.com>
References: <20190902094540.12786-1-janne.karhunen@gmail.com>
	 <20190902094540.12786-2-janne.karhunen@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.20.5 (3.20.5-1.fc24) 
Mime-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19090815-0008-0000-0000-00000312BFF6
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19090815-0009-0000-0000-00004A3120D3
Message-Id: <1567957106.4614.162.camel@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-08_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909080170
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-02 at 12:45 +0300, Janne Karhunen wrote:
> Let IMA know when a file is being opened with truncate
> or truncated directly.
>=20
> Depends on commit 72649b7862a7 ("ima: keep the integrity state of open =
files up to date")'
>=20
> Signed-off-by: Janne Karhunen <janne.karhunen@gmail.com>
> Signed-off-by: Konsta Karsisto <konsta.karsisto@gmail.com>
> ---
>  fs/namei.c | 5 ++++-
>  fs/open.c  | 3 +++
>  2 files changed, 7 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/namei.c b/fs/namei.c
> index 209c51a5226c..0994fe26bef1 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -3418,8 +3418,11 @@ static int do_last(struct nameidata *nd,
>  		goto out;
>  opened:
>  	error =3D ima_file_check(file, op->acc_mode);
> -	if (!error && will_truncate)
> +	if (!error && will_truncate) {
>  		error =3D handle_truncate(file);
> +		if (!error)
> +			ima_file_update(file);

Security and IMA hooks are normally named after the function. =C2=A0For
example, there's a security hook named security_path_truncate() in
handle_truncate(). =C2=A0The new hook after the truncate would either be
named security_post_path_truncate() or ima_post_path_truncate().

> +	}
>  out:
>  	if (unlikely(error > 0)) {
>  		WARN_ON(1);
> diff --git a/fs/open.c b/fs/open.c
> index a59abe3c669a..98c2d4629371 100644
> --- a/fs/open.c
> +++ b/fs/open.c
> @@ -63,6 +63,9 @@ int do_truncate(struct dentry *dentry, loff_t length,=
 unsigned int time_attrs,
>  	/* Note any delegations or leases have already been broken: */
>  	ret =3D notify_change(dentry, &newattrs, NULL);
>  	inode_unlock(dentry->d_inode);
> +
> +	if (filp)
> +		ima_file_update(filp);
>  	return ret;
>  }
> =20

do_truncate() is called from a number of places. =C2=A0Are you sure that
the call to IMA should be in all of them? =C2=A0security_path_truncate()
isn't in all of the callers.

Mimi



