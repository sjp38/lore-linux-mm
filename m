Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56318C4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:35:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DBF620872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:35:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="JUbliCRJ";
	dkim=pass (1024-bit key) header.d=sharedspace.onmicrosoft.com header.i=@sharedspace.onmicrosoft.com header.b="LMMYy7EL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DBF620872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DD7B6B0007; Tue, 10 Sep 2019 04:35:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 767226B0008; Tue, 10 Sep 2019 04:35:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 606CB6B000A; Tue, 10 Sep 2019 04:35:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0224.hostedemail.com [216.40.44.224])
	by kanga.kvack.org (Postfix) with ESMTP id 37D566B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:35:19 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id DA0E08243765
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:35:18 +0000 (UTC)
X-FDA: 75918351516.12.food13_4b4393468c910
X-HE-Tag: food13_4b4393468c910
X-Filterd-Recvd-Size: 13377
Received: from esa1.hgst.iphmx.com (esa1.hgst.iphmx.com [68.232.141.245])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:35:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1568104517; x=1599640517;
  h=from:to:subject:date:message-id:references:
   content-transfer-encoding:mime-version;
  bh=yhkFE1EA/FktOcIhJfm+w4r26LFbKwyv5JLTqiAWU0U=;
  b=JUbliCRJUdV5fdSuEzYeSkbvGWPeFzR7qkz0HUNMRqXlUk8YCKtEJ0Lo
   s1gtWZvuOZUC/O4VZKS1UavEyf/Z4ddY4TqvVK0x6yeDfZHGQ1CkvE2yP
   E8ulL3QxwhPh7NwUy9HesPF08uLQvZ9WyAhzEwSqcmQWk8YuBvYE+MEtS
   OTSK2mvhIpQ6jFy8lP8p+751ilfJWQbfwLTX8VTGLyLGSsbXve0xJ1vvN
   i+qBZmjFTTL4gQJ+J6EhOJwr41/8aZQLtWPvcz4THv3iN/eqND/f3B45P
   kdtYM/7vIWsBE1By0hy3peYIgWuW9hILy5xgyDCEsEpqkIUmB8fS6IpoG
   g==;
IronPort-SDR: 9KwW4IxSAcekiHh/wqpufxhTr1rUbnFD0pStpdMmV1/ZTNS4JLg58+V8FGqL21MTqZ1+/1RsQP
 hZQm50d0qBc+VjaJVdUt/F5K15fXPQt6NDpyb1/+gLMNLsUc9qFjDyW7TuQERLleZ8RqWznN6a
 SXUzCMXnF6rdbBOjAkziHFG0paAgJgO7QHefURBbl/f3nLP4bRgQtpnIepzwHj28H8iElLThNi
 9IwNwrVLSsjppZs2RxK0dPH0FTRcs0R2ddzVp9/rh0Q8oB8vXbu6UW7AILxPzk/lI3p5kFpls3
 7NE=
X-IronPort-AV: E=Sophos;i="5.64,489,1559491200"; 
   d="scan'208";a="224666404"
Received: from mail-bn3nam01lp2055.outbound.protection.outlook.com (HELO NAM01-BN3-obe.outbound.protection.outlook.com) ([104.47.33.55])
  by ob1.hgst.iphmx.com with ESMTP; 10 Sep 2019 16:35:09 +0800
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=EumKfg9zuylrrJhoKXGB8JwCpbTbBTsRX3C930cJWJBJf2DwR3ID9K2G0p7YQi9GYU6zuhrYOx1SnmHMwJ8Qr96RXJhENDNVUgd9sczSofGfUUdw5vYpzSfLSry9cIyRDYF59RcglH3dMOKRECwXON/NBFIBrAVvtXUHjzy7E5v/RuCbnJpQcV92slg7axShdRK3cfZO1CoT3mKcdiZZbdV6ZaGYWQtqn0XUoEFkwuDgAgi5/DmzbHHJx5HERclzVvSv8RI69TfM93oMxNMED3JqYXTjrTf1GefQTWL/vu8k6FyleYFjvN4jYibl0V3tvqWy7p2FbaT5CdobotuwOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/dtCzAgHqHaMqkFXl6TEOQT8DQCpybZCbkMfBpd9GGM=;
 b=kBevn0KQQEReLWPoCMurTMA6nSOJD664cpiKdomQdlze2ndcuchKZa0MFZffGtnQEzEQXGKj73GtuMVFlH8XOhb8FoEW3/UJ+Vae+eUxDL+kB2UjMsdeAVzmds1W2A/jparwp+NnUBj8PXR7keHkTLGgT2YXJLc2C71a6W0cFHngGu8q3J+CcPlOeWLAwlvCFlKullHUV2Cb1O4MYRnSMb2448jYQJ2sURlk+qiQzKBY/dFA72VtTMWHTIFTsc9g9yRiWARWoX9G0zqQ2+l6Nh/XFiXrqNaCnSnRXHh8ZBzpehingS+CxwnUfHTo3hEYYmLmCBLqYDoM4Z7p6axOBw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=wdc.com; dmarc=pass action=none header.from=wdc.com; dkim=pass
 header.d=wdc.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=sharedspace.onmicrosoft.com; s=selector2-sharedspace-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/dtCzAgHqHaMqkFXl6TEOQT8DQCpybZCbkMfBpd9GGM=;
 b=LMMYy7ELwFHUxVJriPyLmGrnBXbaCUaaVsYtpy9nvmaONl96iIKhkVI9O6jK+u9HSH1OH32XGNb7NqqQBn3+hH8/1fbSn7ufuLFgynKfGzQW0Ttg3LRQD+2B0z/2EZBtHtvTLwp5LJzKJCgdZ2DAo+TVbP7VWMoZJj0dZsarp3w=
Received: from BYAPR04MB5816.namprd04.prod.outlook.com (20.179.58.207) by
 BYAPR04MB3893.namprd04.prod.outlook.com (52.135.214.156) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2241.18; Tue, 10 Sep 2019 08:35:08 +0000
Received: from BYAPR04MB5816.namprd04.prod.outlook.com
 ([fe80::50cc:80d2:5c1b:3a10]) by BYAPR04MB5816.namprd04.prod.outlook.com
 ([fe80::50cc:80d2:5c1b:3a10%5]) with mapi id 15.20.2241.018; Tue, 10 Sep 2019
 08:35:08 +0000
From: Damien Le Moal <Damien.LeMoal@wdc.com>
To: Mike Christie <mchristi@redhat.com>, "axboe@kernel.dk" <axboe@kernel.dk>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>, "martin.petersen@oracle.com"
	<martin.petersen@oracle.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-scsi@vger.kernel.org"
	<linux-scsi@vger.kernel.org>, "linux-block@vger.kernel.org"
	<linux-block@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [RFC PATCH] Add proc interface to set PF_MEMALLOC flags
Thread-Topic: [RFC PATCH] Add proc interface to set PF_MEMALLOC flags
Thread-Index: AQHVZyuWq/Op5bBFkEiasB8XvOZqww==
Date: Tue, 10 Sep 2019 08:35:08 +0000
Message-ID:
 <BYAPR04MB5816DABF3C5071D13D823990E7B60@BYAPR04MB5816.namprd04.prod.outlook.com>
References: <20190909162804.5694-1-mchristi@redhat.com>
 <5D76995B.1010507@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Damien.LeMoal@wdc.com; 
x-originating-ip: [199.255.44.250]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: aa997ff8-2028-4968-e5e7-08d735c9c9ab
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:BYAPR04MB3893;
x-ms-traffictypediagnostic: BYAPR04MB3893:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <BYAPR04MB389329007F9BC733B4EA9E42E7B60@BYAPR04MB3893.namprd04.prod.outlook.com>
wdcipoutbound: EOP-TRUE
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 01565FED4C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(346002)(396003)(376002)(366004)(39860400002)(136003)(189003)(199004)(15374003)(14444005)(186003)(8936002)(81166006)(25786009)(6116002)(91956017)(76116006)(8676002)(6506007)(53546011)(52536014)(478600001)(966005)(7736002)(7696005)(256004)(81156014)(66066001)(86362001)(26005)(102836004)(64756008)(66446008)(66556008)(66476007)(66946007)(476003)(446003)(99286004)(229853002)(110136005)(53936002)(3846002)(74316002)(486006)(6306002)(305945005)(55016002)(6246003)(316002)(2201001)(2501003)(14454004)(5660300002)(71200400001)(71190400001)(2906002)(6436002)(76176011)(33656002)(9686003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR04MB3893;H:BYAPR04MB5816.namprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 PmizGDm9W1coGXbuwZBJ/k9NmfmIVo8gFuhwpH4+Qm0R1+ZGbkHSno+4nc8veG0XUdDIjC3SfjP7SvzWL90ITo0ffHY1vRUo2bpQjtfPylljEAWhPdOypbkRruRKJbSBOQOIQUBuWyRHE5z7TIHNKboruH2vqSJ+T/usM5VjNRqLu5zX/cSzTwSpcOXKjC3m0QOXiDZNXuCnFhIFIlkdeRueYZjiDIT7k5rk6cL+ZUnGLSXTWJkQMRVffT8KlS0LtF8uGiIuD6hza4rRnbwdkJfIjDlvjSEOEOyESKeDPNozRdlFZc4av9bbA8ryK9MvMI9hpd+NaQpVwJK35fRjGSB7brgO2rfInxASe53bBQP4hMG3fT6q3kRCbW/iQouIL+usiIXph2oQiAMtiqM/WXrfC/IrkJFP5aQ7p5WyN+Y=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: wdc.com
X-MS-Exchange-CrossTenant-Network-Message-Id: aa997ff8-2028-4968-e5e7-08d735c9c9ab
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 Sep 2019 08:35:08.2260
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b61c8803-16f3-4c35-9b17-6f65f441df86
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: /uVJbG/TZ6odIlFgIRBkk1+ehfkpL8D0z4HSpnYc+I8qpwmTYseinKoxaMAskfg0mDe+6PYVqjK/iVp2aAldFg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR04MB3893
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mike,=0A=
=0A=
On 2019/09/09 19:26, Mike Christie wrote:=0A=
> Forgot to cc linux-mm.=0A=
> =0A=
> On 09/09/2019 11:28 AM, Mike Christie wrote:=0A=
>> There are several storage drivers like dm-multipath, iscsi, and nbd that=
=0A=
>> have userspace components that can run in the IO path. For example,=0A=
>> iscsi and nbd's userspace deamons may need to recreate a socket and/or=
=0A=
>> send IO on it, and dm-multipath's daemon multipathd may need to send IO=
=0A=
>> to figure out the state of paths and re-set them up.=0A=
>>=0A=
>> In the kernel these drivers have access to GFP_NOIO/GFP_NOFS and the=0A=
>> memalloc_*_save/restore functions to control the allocation behavior,=0A=
>> but for userspace we would end up hitting a allocation that ended up=0A=
>> writing data back to the same device we are trying to allocate for.=0A=
>>=0A=
>> This patch allows the userspace deamon to set the PF_MEMALLOC* flags=0A=
>> through procfs. It currently only supports PF_MEMALLOC_NOIO, but=0A=
>> depending on what other drivers and userspace file systems need, for=0A=
>> the final version I can add the other flags for that file or do a file=
=0A=
>> per flag or just do a memalloc_noio file.=0A=
=0A=
Awesome. That probably will be the perfect solution for the problem we hit =
with=0A=
tcmu-runner a while back (please see this thread:=0A=
https://www.spinics.net/lists/linux-fsdevel/msg148912.html).=0A=
=0A=
I think we definitely need nofs as well for dealing with cases where the ba=
ckend=0A=
storage for the user daemon is a file.=0A=
=0A=
I will give this patch a try as soon as possible (I am traveling currently)=
.=0A=
=0A=
Best regards.=0A=
=0A=
>>=0A=
>> Signed-off-by: Mike Christie <mchristi@redhat.com>=0A=
>> ---=0A=
>>  Documentation/filesystems/proc.txt |  6 ++++=0A=
>>  fs/proc/base.c                     | 53 ++++++++++++++++++++++++++++++=
=0A=
>>  2 files changed, 59 insertions(+)=0A=
>>=0A=
>> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesyst=
ems/proc.txt=0A=
>> index 99ca040e3f90..b5456a61a013 100644=0A=
>> --- a/Documentation/filesystems/proc.txt=0A=
>> +++ b/Documentation/filesystems/proc.txt=0A=
>> @@ -46,6 +46,7 @@ Table of Contents=0A=
>>    3.10  /proc/<pid>/timerslack_ns - Task timerslack value=0A=
>>    3.11	/proc/<pid>/patch_state - Livepatch patch operation state=0A=
>>    3.12	/proc/<pid>/arch_status - Task architecture specific information=
=0A=
>> +  3.13  /proc/<pid>/memalloc - Control task's memory reclaim behavior=
=0A=
>>  =0A=
>>    4	Configuring procfs=0A=
>>    4.1	Mount options=0A=
>> @@ -1980,6 +1981,11 @@ Example=0A=
>>   $ cat /proc/6753/arch_status=0A=
>>   AVX512_elapsed_ms:      8=0A=
>>  =0A=
>> +3.13 /proc/<pid>/memalloc - Control task's memory reclaim behavior=0A=
>> +-----------------------------------------------------------------------=
=0A=
>> +A value of "noio" indicates that when a task allocates memory it will n=
ot=0A=
>> +reclaim memory that requires starting phisical IO.=0A=
>> +=0A=
>>  Description=0A=
>>  -----------=0A=
>>  =0A=
>> diff --git a/fs/proc/base.c b/fs/proc/base.c=0A=
>> index ebea9501afb8..c4faa3464602 100644=0A=
>> --- a/fs/proc/base.c=0A=
>> +++ b/fs/proc/base.c=0A=
>> @@ -1223,6 +1223,57 @@ static const struct file_operations proc_oom_scor=
e_adj_operations =3D {=0A=
>>  	.llseek		=3D default_llseek,=0A=
>>  };=0A=
>>  =0A=
>> +static ssize_t memalloc_read(struct file *file, char __user *buf, size_=
t count,=0A=
>> +			     loff_t *ppos)=0A=
>> +{=0A=
>> +	struct task_struct *task;=0A=
>> +	ssize_t rc =3D 0;=0A=
>> +=0A=
>> +	task =3D get_proc_task(file_inode(file));=0A=
>> +	if (!task)=0A=
>> +		return -ESRCH;=0A=
>> +=0A=
>> +	if (task->flags & PF_MEMALLOC_NOIO)=0A=
>> +		rc =3D simple_read_from_buffer(buf, count, ppos, "noio", 4);=0A=
>> +	put_task_struct(task);=0A=
>> +	return rc;=0A=
>> +}=0A=
>> +=0A=
>> +static ssize_t memalloc_write(struct file *file, const char __user *buf=
,=0A=
>> +			      size_t count, loff_t *ppos)=0A=
>> +{=0A=
>> +	struct task_struct *task;=0A=
>> +	char buffer[5];=0A=
>> +	int rc =3D count;=0A=
>> +=0A=
>> +	memset(buffer, 0, sizeof(buffer));=0A=
>> +	if (count !=3D sizeof(buffer) - 1)=0A=
>> +		return -EINVAL;=0A=
>> +=0A=
>> +	if (copy_from_user(buffer, buf, count))=0A=
>> +		return -EFAULT;=0A=
>> +	buffer[count] =3D '\0';=0A=
>> +=0A=
>> +	task =3D get_proc_task(file_inode(file));=0A=
>> +	if (!task)=0A=
>> +		return -ESRCH;=0A=
>> +=0A=
>> +	if (!strcmp(buffer, "noio")) {=0A=
>> +		task->flags |=3D PF_MEMALLOC_NOIO;=0A=
>> +	} else {=0A=
>> +		rc =3D -EINVAL;=0A=
>> +	}=0A=
>> +=0A=
>> +	put_task_struct(task);=0A=
>> +	return rc;=0A=
>> +}=0A=
>> +=0A=
>> +static const struct file_operations proc_memalloc_operations =3D {=0A=
>> +	.read		=3D memalloc_read,=0A=
>> +	.write		=3D memalloc_write,=0A=
>> +	.llseek		=3D default_llseek,=0A=
>> +};=0A=
>> +=0A=
>>  #ifdef CONFIG_AUDIT=0A=
>>  #define TMPBUFLEN 11=0A=
>>  static ssize_t proc_loginuid_read(struct file * file, char __user * buf=
,=0A=
>> @@ -3097,6 +3148,7 @@ static const struct pid_entry tgid_base_stuff[] =
=3D {=0A=
>>  #ifdef CONFIG_PROC_PID_ARCH_STATUS=0A=
>>  	ONE("arch_status", S_IRUGO, proc_pid_arch_status),=0A=
>>  #endif=0A=
>> +	REG("memalloc", S_IRUGO|S_IWUSR, proc_memalloc_operations),=0A=
>>  };=0A=
>>  =0A=
>>  static int proc_tgid_base_readdir(struct file *file, struct dir_context=
 *ctx)=0A=
>> @@ -3487,6 +3539,7 @@ static const struct pid_entry tid_base_stuff[] =3D=
 {=0A=
>>  #ifdef CONFIG_PROC_PID_ARCH_STATUS=0A=
>>  	ONE("arch_status", S_IRUGO, proc_pid_arch_status),=0A=
>>  #endif=0A=
>> +	REG("memalloc", S_IRUGO|S_IWUSR, proc_memalloc_operations),=0A=
>>  };=0A=
>>  =0A=
>>  static int proc_tid_base_readdir(struct file *file, struct dir_context =
*ctx)=0A=
>>=0A=
> =0A=
> =0A=
=0A=
=0A=
-- =0A=
Damien Le Moal=0A=
Western Digital Research=0A=

