Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88C7A6B7F54
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 02:48:59 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id x3so1004405wru.22
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 23:48:59 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::10])
        by mx.google.com with ESMTPS id y123si2097956wmy.152.2018.12.06.23.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 23:48:58 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
In-Reply-To: <20181206193605.GA31255@lst.de>
Date: Fri, 7 Dec 2018 08:48:54 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <EC9C556C-B445-4E55-80DA-D5A04C701044@xenosoft.de>
References: <8694431d-c669-b7b9-99fa-e99db5d45a7d@xenosoft.de> <20181130131056.GA5211@lst.de> <25999587-2d91-a63c-ed38-c3fb0075d9f1@xenosoft.de> <c5202d29-863d-1377-0e2d-762203b317e2@xenosoft.de> <58c61afb-290f-6196-c72c-ac7b61b84718@xenosoft.de> <20181204142426.GA2743@lst.de> <ef56d279-f75d-008e-71ba-7068c1b37c48@xenosoft.de> <20181205140550.GA27549@lst.de> <1948cf84-49ab-543c-472c-d18e27751903@xenosoft.de> <9ECD27D6-B039-4253-9FB9-749B41DE4CC6@xenosoft.de> <20181206193605.GA31255@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

Good to know. Sorry because of the email.

Sent from my iPhone

> On 6. Dec 2018, at 20:36, Christoph Hellwig <hch@lst.de> wrote:
>=20
>> On Thu, Dec 06, 2018 at 06:10:54PM +0100, Christian Zigotzky wrote:
>> Please don=E2=80=99t merge this code. We are still testing and trying to f=
igure out where the problems are in the code.
>=20
> The ones I sent pings for were either tested successfully by you
> (the zone change) or are trivial cleanups that don't affect your setup.
