Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86F17C282C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:49:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3321621872
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:49:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=javigon-com.20150623.gappssmtp.com header.i=@javigon-com.20150623.gappssmtp.com header.b="vpcmb6Fk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3321621872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=javigon.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA9378E0057; Thu,  7 Feb 2019 12:49:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B59AA8E0002; Thu,  7 Feb 2019 12:49:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69E568E0057; Thu,  7 Feb 2019 12:49:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 107008E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 12:49:02 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t7so241705edr.21
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 09:49:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:message-id:mime-version
         :subject:date:in-reply-to:cc:to:references;
        bh=ocu5g2rTb/Tzi1s34Q0T/jBgeZO/Q/AzE2x6fj/vZYE=;
        b=fDCVQdlE114Q/AaLi79gpSbuQ2SlENZx+b8Qxhc3Mkm7fxV8jd2w5EJgukXkpy54W+
         5menJJllTsVUa3ZFSEh0jM1NLigDRrbdjdhAcHYCcDL1xPNnf/sz4iQzq7TcznahZRxq
         ChPwGVhC4Bdj4A4+jiB38jjCNf4HJzIAY1anljhVvYLOItM/CO4iqqBSljHtjfEBbCOf
         GwhjJ/PYfI9/j+3TgY2RWsWx+tijBFnwEhvj6DHDBTkIiceIddt4zx4tZea38Fyc/9BF
         vGccjOLYrXC0XBkpOc3jTdbAJ/BUhdb9wrMkxe+J33ndcE/VuEqxZ+Vj9pwKINQWwobJ
         Xxjw==
X-Gm-Message-State: AHQUAuaBnB0KPhBJYSnyXuMDlVWtIeRBQcImHEI2sa4YyiA543r4OQ8H
	ZnshotELu9R4ht3nTxbgGWUDpVYdKWs6fvViSEBSi7oAeA1JFdgKA3OXuN1dC99STTW9KVsYQJt
	iAouRZ9RLhyft7vjb2Pw4QCqQjTeL/ZskDTiP7aUpvhrtO5rrs1ETHsQjCvjr633fd+W+GSFrEe
	jgKesVcUHy51mfwn1SBpOoMAHibyk7KDCijAUDU+xp0EIst0QouNlO8afnBAyGe7NlTHVv+MAtZ
	CLdaz79lEhwgSDUjZbYZq4exhFVvuArBXu80ZhRA0x+LhjentQSqWA6l+g6M9Vv7XkyweZ3eLDL
	r8Be7Hs+5YJ7E/qMQSOMkGxnHe/aA8KoxzNXQe38JGYHZ6V3neVZ6JiY6VKR0C0lYw4/I/GCAo+
	e
X-Received: by 2002:a17:906:ee2:: with SMTP id x2mr12689162eji.202.1549561741585;
        Thu, 07 Feb 2019 09:49:01 -0800 (PST)
X-Received: by 2002:a17:906:ee2:: with SMTP id x2mr12689110eji.202.1549561740649;
        Thu, 07 Feb 2019 09:49:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549561740; cv=none;
        d=google.com; s=arc-20160816;
        b=pYTox9FN9MkTqWWsAPTnmJGvPO3FshCjihO89u1AurlVkqPJ3ti1m2OLxZivLoeHhh
         Vp4O0zbm1V+w1z141KP8gferwtLYrfeuWy53ru/vbw8FzDwlFeJSGQKfGegosCxpt/+n
         4avjpz4bOqtKjE2uUmVxl1PB/+JTXHEZNlfVwf36jCoJ5pfvjSogQcZUboauS6kM0EoJ
         NHqhm3MDIQHk/9T5KGdAoslK+rcRMClkcfARC9gcm1FgVhRKLL6YQNSYc+Sw4Cxj0/wF
         X0vukjJbAnr/7HqgvJ8jCAVZ2fj/QlwRG5rmi3GDUyj7tsCglwgz+BzO9gdVD8E5Hgj0
         Wgdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
         :from:dkim-signature;
        bh=ocu5g2rTb/Tzi1s34Q0T/jBgeZO/Q/AzE2x6fj/vZYE=;
        b=zid/CofqzlfR0cZCXZV0DmNKz0qiy4JOnWFYoyGuZ+g9FjZ+jTuWsI/cQN2tPiEGiX
         LUouC15zStVnPXr0ou5k//XpAZgAqrl/X43gCLitN2VzJR4l4VzmhtGZjHVUiQJpy1FJ
         nagijGq9EZkCFVQAvVKUjt/gVCa/QOh04fkAvmXbWe5cckVHdmnJqB8Soqxn7U868f+J
         PO1cK0R67XCF7V1FX+d3j9aEAkrFJSwP7ZddMeVntJ+3Pk5iSCmfpJ3FE7Lcns83S/jN
         eU9WXljbOiSJpeHsbjXJ2AEweOehcOLmoeDgEgAT6e1N+PR9CQYQkfgJ7Li6MyUg5B7x
         DK+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@javigon-com.20150623.gappssmtp.com header.s=20150623 header.b=vpcmb6Fk;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of javier@javigon.com) smtp.mailfrom=javier@javigon.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m21sor1741974ejz.46.2019.02.07.09.49.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 09:49:00 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of javier@javigon.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@javigon-com.20150623.gappssmtp.com header.s=20150623 header.b=vpcmb6Fk;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of javier@javigon.com) smtp.mailfrom=javier@javigon.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=javigon-com.20150623.gappssmtp.com; s=20150623;
        h=from:message-id:mime-version:subject:date:in-reply-to:cc:to
         :references;
        bh=ocu5g2rTb/Tzi1s34Q0T/jBgeZO/Q/AzE2x6fj/vZYE=;
        b=vpcmb6FkY1IAmYBkfPHuOMsqIYID60knYjXCjuteox2RS/xRTeSiZCnJfVstY/7EJc
         +BQCWZrrbZdwcyfAcaZsF7j1NHzJ2icgzQ72SrKNyxBf80ECZFsMhuMVAVeXpiF/a2gc
         aEamBhBaXfh/odCATbwbXpZUWJBkDuqKlA2b48+jAoxjak5Z3mDPVkyHTxZLXDeLMte/
         kkExm/hgbEIdb4RmZaiiF+XLkcoQv0OQu85IZZw8HhxlqNgMzAmhrtkrjDAkA3ELpfCM
         IxZGekfVuyFI+wzHY8E+8iQSbBvfALHEDU6HapnfrINSz5KYq+MwbgSAmv/wmexHayI9
         Ed2Q==
X-Google-Smtp-Source: AHgI3IbDvVGxaIt+a2/vDBNYOeYqBN1U46VqohxgxeQd6gWMAppUgHlvpThdKO8S1t432FaOh0dHXw==
X-Received: by 2002:a17:906:2d51:: with SMTP id e17-v6mr12092615eji.143.1549561740009;
        Thu, 07 Feb 2019 09:49:00 -0800 (PST)
Received: from [192.168.1.143] (ip-5-186-122-168.cgn.fibianet.dk. [5.186.122.168])
        by smtp.gmail.com with ESMTPSA id c30sm7011214edc.70.2019.02.07.09.48.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 09:48:59 -0800 (PST)
From: =?utf-8?Q?Javier_Gonz=C3=A1lez?= <javier@javigon.com>
Message-Id: <04952865-6EEE-4D78-8CC9-00484CFBD13E@javigon.com>
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_A250CE3E-57B8-4B39-BA06-72130E79B090"
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [LSF/MM TOPIC] BPF for Block Devices
Date: Thu, 7 Feb 2019 18:48:58 +0100
In-Reply-To: <40D2EB06-6BF2-4233-9196-7A26AC43C64E@raithlin.com>
Cc: Jens Axboe <axboe@kernel.dk>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>,
 "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
 IDE/ATA development list <linux-ide@vger.kernel.org>,
 linux-scsi <linux-scsi@vger.kernel.org>,
 "linux-nvme@lists.infradead.org" <linux-nvme@lists.infradead.org>,
 Logan Gunthorpe <logang@deltatee.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
 "bpf@vger.kernel.org" <bpf@vger.kernel.org>,
 "ast@kernel.org" <ast@kernel.org>
To: Stephen Bates <sbates@raithlin.com>
References: <40D2EB06-6BF2-4233-9196-7A26AC43C64E@raithlin.com>
X-Mailer: Apple Mail (2.3445.101.1)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--Apple-Mail=_A250CE3E-57B8-4B39-BA06-72130E79B090
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8



> On 7 Feb 2019, at 18.12, Stephen Bates <sbates@raithlin.com> wrote:
>=20
> Hi All
>=20
>> A BPF track will join the annual LSF/MM Summit this year! Please read =
the updated description and CFP information below.
>=20
> Well if we are adding BPF to LSF/MM I have to submit a request to =
discuss BPF for block devices please!
>=20
> There has been quite a bit of activity around the concept of =
Computational Storage in the past 12 months. SNIA recently formed a =
Technical Working Group (TWG) and it is expected that this TWG will be =
making proposals to standards like NVM Express to add APIs for =
computation elements that reside on or near block devices.
>=20
> While some of these Computational Storage accelerators will provide =
fixed functions (e.g. a RAID, encryption or compression), others will be =
more flexible. Some of these flexible accelerators will be capable of =
running BPF code on them (something that certain Linux drivers for =
SmartNICs support today [1]). I would like to discuss what such a =
framework could look like for the storage layer and the file-system =
layer. I'd like to discuss how devices could advertise this capability =
(a special type of NVMe namespace or SCSI LUN perhaps?) and how the BPF =
engine could be programmed and then used against block IO. Ideally I'd =
like to discuss doing this in a vendor-neutral way and develop ideas I =
can take back to NVMe and the SNIA TWG to help shape how these standard =
evolve.
>=20
> To provide an example use-case one could consider a BPF capable =
accelerator being used to perform a filtering function and then using =
p2pdma to scan data on a number of adjacent NVMe SSDs, filtering said =
data and then only providing filter-matched LBAs to the host. Many other =
potential applications apply.=20
>=20
> Also, I am interested in the "The end of the DAX Experiment" topic =
proposed by Dan and the " Zoned Block Devices" from Matias and Damien.
>=20
> Cheers
>=20
> Stephen
>=20
> [1] =
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/dr=
ivers/net/ethernet/netronome/nfp/bpf/offload.c?h=3Dv5.0-rc5 =
<https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/d=
rivers/net/ethernet/netronome/nfp/bpf/offload.c?h=3Dv5.0-rc5>

Definitely interested on this too - and pleasantly surprised to see a =
BPF track!

I would like to extend Stephen=E2=80=99s discussion to eBPF running in =
the block layer directly - both on the kernel VM and offloaded to the =
accelerator of choice. This would be like XDP on the storage stack, =
possibly with different entry points. I have been doing some experiments =
building a dedup engine for pblk in the last couple of weeks and a =
number of interesting questions have arisen.

Also, if there is a discussion on offloading the eBPF to an accelerator, =
I would like to discuss how we can efficiently support data =
modifications without having double transfers over either the PCIe bus =
(or worse, over the network): one for the data computation + =
modification and another for the actual data transfer. Something like =
p2pmem comes to mind here, but for this to integrate nicely, we would =
need to overcome the current limitations on PCIe and talk about p2pmem =
over fabrics.

Javier=

--Apple-Mail=_A250CE3E-57B8-4B39-BA06-72130E79B090
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D""><br =
class=3D""><div><br class=3D""><blockquote type=3D"cite" class=3D""><div =
class=3D"">On 7 Feb 2019, at 18.12, Stephen Bates &lt;<a =
href=3D"mailto:sbates@raithlin.com" class=3D"">sbates@raithlin.com</a>&gt;=
 wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><div =
class=3D"">Hi All<br class=3D""><br class=3D""><blockquote type=3D"cite" =
class=3D"">A BPF track will join the annual LSF/MM Summit this year! =
Please read the updated description and CFP information below.<br =
class=3D""></blockquote><br class=3D"">Well if we are adding BPF to =
LSF/MM I have to submit a request to discuss BPF for block devices =
please!<br class=3D""><br class=3D"">There has been quite a bit of =
activity around the concept of Computational Storage in the past 12 =
months. SNIA recently formed a Technical Working Group (TWG) and it is =
expected that this TWG will be making proposals to standards like NVM =
Express to add APIs for computation elements that reside on or near =
block devices.<br class=3D""><br class=3D"">While some of these =
Computational Storage accelerators will provide fixed functions (e.g. a =
RAID, encryption or compression), others will be more flexible. Some of =
these flexible accelerators will be capable of running BPF code on them =
(something that certain Linux drivers for SmartNICs support today [1]). =
I would like to discuss what such a framework could look like for the =
storage layer and the file-system layer. I'd like to discuss how devices =
could advertise this capability (a special type of NVMe namespace or =
SCSI LUN perhaps?) and how the BPF engine could be programmed and then =
used against block IO. Ideally I'd like to discuss doing this in a =
vendor-neutral way and develop ideas I can take back to NVMe and the =
SNIA TWG to help shape how these standard evolve.<br class=3D""><br =
class=3D"">To provide an example use-case one could consider a BPF =
capable accelerator being used to perform a filtering function and then =
using p2pdma to scan data on a number of adjacent NVMe SSDs, filtering =
said data and then only providing filter-matched LBAs to the host. Many =
other potential applications apply. <br class=3D""><br class=3D"">Also, =
I am interested in the "The end of the DAX Experiment" topic proposed by =
Dan and the " Zoned Block Devices" from Matias and Damien.<br =
class=3D""><br class=3D"">Cheers<br class=3D""><br class=3D"">Stephen<br =
class=3D""><br class=3D"">[1] <a =
href=3D"https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git=
/tree/drivers/net/ethernet/netronome/nfp/bpf/offload.c?h=3Dv5.0-rc5" =
class=3D"">https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.=
git/tree/drivers/net/ethernet/netronome/nfp/bpf/offload.c?h=3Dv5.0-rc5</a>=
<br class=3D""></div></div></blockquote><div><br =
class=3D""></div>Definitely interested on this too - and pleasantly =
surprised to see a BPF track!</div><div><br class=3D""></div><div>I =
would like to extend Stephen=E2=80=99s discussion to eBPF running in the =
block layer directly - both on the kernel VM and offloaded to the =
accelerator of choice. This would be like XDP on the storage stack, =
possibly with different entry points. I have been doing some experiments =
building a dedup engine for pblk in the last couple of weeks and a =
number of interesting questions have arisen.</div><div><br =
class=3D""></div><div>Also, if there is a discussion on offloading the =
eBPF to an accelerator, I would like to discuss how we can efficiently =
support data modifications without having double transfers over either =
the PCIe bus (or worse, over the network): one for the data computation =
+ modification and another for the actual data transfer. Something like =
p2pmem comes to mind here, but for this to integrate nicely, we would =
need to overcome the current limitations on PCIe and talk about p2pmem =
over fabrics.</div><div><br =
class=3D""></div><div>Javier</div></body></html>=

--Apple-Mail=_A250CE3E-57B8-4B39-BA06-72130E79B090--

