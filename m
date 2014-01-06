Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 114C46B0035
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 17:33:18 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id a1so3041386wgh.3
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 14:33:18 -0800 (PST)
Received: from mailuogwdur.emc.com (mailuogwdur.emc.com. [128.221.224.79])
        by mx.google.com with ESMTPS id q3si25246206wjq.116.2014.01.06.14.33.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 14:33:18 -0800 (PST)
From: "faibish, sorin" <faibish_sorin@emc.com>
Date: Mon, 6 Jan 2014 17:32:56 -0500
Subject: RE: [LSF/MM TOPIC] [ATTEND] persistent memory progress, management
 of storage & file systems
Message-ID: <2512424DBC01FD48843E938C780FA97C02B002A583@MX23A.corp.emc.com>
References: <20131220093022.GV11295@suse.de> <52CB2C3A.3010207@gmail.com>
In-Reply-To: <52CB2C3A.3010207@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Wheeler <ricwheeler@gmail.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Speaking of persistent memory I would like to discuss the PMFS as well as R=
DMA aspects of the persistent memory model. Also I would like to discuss KV=
 stores and object stores on persistent memory. I was involved in the PMFS =
as a tester and I found several issues that I would like to discuss with th=
e community. I assume that maybe others from Intel could join this discussi=
on except for Andy and Matt which already asked for this topic. Thanks

./Sorin

-----Original Message-----
From: linux-fsdevel-owner@vger.kernel.org [mailto:linux-fsdevel-owner@vger.=
kernel.org] On Behalf Of Ric Wheeler
Sent: Monday, January 06, 2014 5:21 PM
To: linux-scsi@vger.kernel.org; linux-ide@vger.kernel.org; linux-mm@kvack.o=
rg; linux-fsdevel@vger.kernel.org; lsf-pc@lists.linux-foundation.org
Cc: linux-kernel@vger.kernel.org
Subject: [LSF/MM TOPIC] [ATTEND] persistent memory progress, management of =
storage & file systems


I would like to attend this year and continue to talk about the work on ena=
bling the new class of persistent memory devices. Specifically, very intere=
sted in talking about both using a block driver under our existing stack an=
d also progress at the file system layer (adding xip/mmap tweaks to existin=
g file systems and looking at new file systems).

We also have a lot of work left to do on unifying management, it would be g=
ood to resync on that.

Regards,

Ric

--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in=
 the body of a message to majordomo@vger.kernel.org More majordomo info at =
 http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
