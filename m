Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A371C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:53:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E23F522DD3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 16:53:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PbJtDOQU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E23F522DD3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6419C6B0320; Wed, 21 Aug 2019 12:53:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F10F6B0321; Wed, 21 Aug 2019 12:53:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 505EB6B0322; Wed, 21 Aug 2019 12:53:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0233.hostedemail.com [216.40.44.233])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF126B0320
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 12:53:55 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C12118248AC3
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:53:54 +0000 (UTC)
X-FDA: 75847031988.16.judge04_3f34edd479231
X-HE-Tag: judge04_3f34edd479231
X-Filterd-Recvd-Size: 9594
Received: from mail-vs1-f68.google.com (mail-vs1-f68.google.com [209.85.217.68])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 16:53:54 +0000 (UTC)
Received: by mail-vs1-f68.google.com with SMTP id y62so1844532vsb.6
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 09:53:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=ndUVDQIfLRdQBKzX32bM7J13PSbKAKphoNFnRjrYT4E=;
        b=PbJtDOQUIlcdrgJOIRF0Wya7gKusKlvPgpphbo5RlhL7cfAFFjzSrmznH+WM/LyZrU
         Bc9l87rf+oH8g1V+/tyEhyp8V7nVYxxS6V8mcSqxWoahZIdmClxx+gHUixTnKYktjVWJ
         MfjYwqgT2zCKHI8lNZ2lVAe8psvkRgwN2e3HzUZhHgZJzaBYsTOl3yT1kYTxHEqUwf9J
         4cpbC3FZ8SmGCTA0jJhFd4u+3bDOMRJJvqI5pgW3NTy0YV9Z0UYIsbz65bWjfwYZ2cxr
         x57gVujt5CBZvZwF333xW1XPTbyYcgVZlQzeVYLW+l00gnDGABldJM8P5yGuhQ7KartD
         k0PQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=ndUVDQIfLRdQBKzX32bM7J13PSbKAKphoNFnRjrYT4E=;
        b=U60sow6h5IA1IgmEVLQqhIfMUjk7BQ2wb2aI+l/Bk3zai+47kG4NS/rOlJNlCW6OBT
         XJHHAKm9eDu+NF+yOnPtBOKy/Fw20Ft9bS8VkY93IIowh5lRuyeRKtFMgYld662tJc3C
         O5a8D/wVufAbP/xgoi2piWsQO1ZYD56YH+fNOr8jaV6SbxeWFnEuiiYKcoiVC517vWyj
         HgpYuAkGFIemZagcvT7H8HzSt6h9jScA+nL0tPPBuAQOkjkFugj8f61hjSdT50XsJ9Qv
         inM59cSQtBwMksSMus2OJ43FUm7ya5HIo+rvyUS7yn59rpZdYz+mRgGUt3v8QyPz5l4Y
         jMLQ==
X-Gm-Message-State: APjAAAURRGtqPsQIBsidh1DG0j13YhNonlZmn4/xK7fGZoGpce8rKkQd
	jsgbi8i8mb9uJD1EwltSCxSBtCZL5LIAfIyhOFo=
X-Google-Smtp-Source: APXvYqzXMTRDb6/l9LK0t7srRCSTXSdlQxCt7VupRsaOFeCxEgvT62uJ/Kn5IqGkTj6z6/dQKUq9DMyBuBOdzyk/znA=
X-Received: by 2002:a67:7043:: with SMTP id l64mr21876722vsc.55.1566406433561;
 Wed, 21 Aug 2019 09:53:53 -0700 (PDT)
MIME-Version: 1.0
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Wed, 21 Aug 2019 22:23:44 +0530
Message-ID: <CACDBo57u+sgordDvFpTzJ=U4mT8uVz7ZovJ3qSZQCrhdYQTw0A@mail.gmail.com>
Subject: PageBlocks and Migrate Types
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, pankaj.suryawanshi@einfochips.com
Content-Type: multipart/alternative; boundary="0000000000000be3ff0590a36bae"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.059125, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000000be3ff0590a36bae
Content-Type: text/plain; charset="UTF-8"

Hello,

1. What are Pageblocks and migrate types(MIGRATE_CMA) in Linux memory ?
How many movable/unmovable pages are defined by default?
With 2GB of memory, how many movable and unmovable pages are defined by
default ?
Example - cat /proc/pagetypeinfo :- Kernel Version - 4.14 CPU Architecture
- ARM 32-bit

Page block order: 12
Pages per block:  4096

Free pages count per migrate type at order       0      1      2      3
 4      5      6      7      8      9     10     11     12
Node    0, zone      DMA, type    Unmovable     71    235    137     30
17      7      2      0      0      1      1      0      0
Node    0, zone      DMA, type      Movable      0      1      1      0
 1      0      0      1      0      1      0      3      9
Node    0, zone      DMA, type  Reclaimable      0      0      1      2
 0      0      0      0      1      1      1      1      0
Node    0, zone      DMA, type   HighAtomic      0      0      0      0
 0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type          CMA      0      0      0      0
 0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type      Isolate      0      0      0      0
 0      0      0      0      0      0      0      0      0
Node    0, zone  HighMem, type    Unmovable     55     47     16      8
 6      2      1      0      0      0      0      1      0
Node    0, zone  HighMem, type      Movable      0      0      0      0
 0      0      0      0      0      0      0      0      0
Node    0, zone  HighMem, type  Reclaimable      0      0      0      0
 0      0      0      0      0      0      0      0      0
Node    0, zone  HighMem, type   HighAtomic      0      0      0      0
 0      0      0      0      0      0      0      0      0
Node    0, zone  HighMem, type          CMA    261    915    778    204
48     20      5      0      0      0      0      1     13
Node    0, zone  HighMem, type      Isolate      0      0      0      0
 0      0      0      0      0      0      0      0      0


Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic
         CMA      Isolate

Node 0, zone      DMA           10           14            4            0
         0            0
Node 0, zone  HighMem            3           32            0            0
        57            0


Regards,
Pankaj

--0000000000000be3ff0590a36bae
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: base64

PGRpdiBkaXI9Imx0ciI+PGRpdj48YnI+PC9kaXY+SGVsbG8sPGJyPjxkaXY+PGJyPjEuIFdoYXQg
YXJlIFBhZ2VibG9ja3MgYW5kIG1pZ3JhdGUgdHlwZXMoTUlHUkFURV9DTUEpIGluIExpbnV4IG1l
bW9yeSA/PGJyPkhvdyBtYW55IG1vdmFibGUvdW5tb3ZhYmxlIHBhZ2VzIGFyZSBkZWZpbmVkIGJ5
IGRlZmF1bHQ/PGJyPldpdGggMkdCIG9mIG1lbW9yeSwgaG93IG1hbnkgbW92YWJsZSBhbmQgdW5t
b3ZhYmxlIHBhZ2VzIGFyZSBkZWZpbmVkIGJ5IGRlZmF1bHQgPzxicj5FeGFtcGxlIC0gY2F0IC9w
cm9jL3BhZ2V0eXBlaW5mbyA6LSBLZXJuZWwgVmVyc2lvbiAtIDQuMTQgQ1BVIEFyY2hpdGVjdHVy
ZSAtIEFSTSAzMi1iaXQ8YnI+PGJyPlBhZ2UgYmxvY2sgb3JkZXI6IDEyIDxicj5QYWdlcyBwZXIg
YmxvY2s6IMKgNDA5Njxicj48YnI+RnJlZSBwYWdlcyBjb3VudCBwZXIgbWlncmF0ZSB0eXBlIGF0
IG9yZGVyIMKgIMKgIMKgIDAgwqAgwqAgwqAxIMKgIMKgIMKgMiDCoCDCoCDCoDMgwqAgwqAgwqA0
IMKgIMKgIMKgNSDCoCDCoCDCoDYgwqAgwqAgwqA3IMKgIMKgIMKgOCDCoCDCoCDCoDkgwqAgwqAg
MTAgwqAgwqAgMTEgwqAgwqAgMTI8YnI+Tm9kZSDCoCDCoDAsIHpvbmUgwqAgwqAgwqBETUEsIHR5
cGUgwqAgwqBVbm1vdmFibGUgwqAgwqAgNzEgwqAgwqAyMzUgwqAgwqAxMzcgwqAgwqAgMzAgwqAg
wqAgMTcgwqAgwqAgwqA3IMKgIMKgIMKgMiDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMSDC
oCDCoCDCoDEgwqAgwqAgwqAwIMKgIMKgIMKgMCA8YnI+Tm9kZSDCoCDCoDAsIHpvbmUgwqAgwqAg
wqBETUEsIHR5cGUgwqAgwqAgwqBNb3ZhYmxlIMKgIMKgIMKgMCDCoCDCoCDCoDEgwqAgwqAgwqAx
IMKgIMKgIMKgMCDCoCDCoCDCoDEgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDEgwqAgwqAg
wqAwIMKgIMKgIMKgMSDCoCDCoCDCoDAgwqAgwqAgwqAzIMKgIMKgIMKgOSDCoDxicj5Ob2RlIMKg
IMKgMCwgem9uZSDCoCDCoCDCoERNQSwgdHlwZSDCoFJlY2xhaW1hYmxlIMKgIMKgIMKgMCDCoCDC
oCDCoDAgwqAgwqAgwqAxIMKgIMKgIMKgMiDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDC
oCDCoCDCoDAgwqAgwqAgwqAxIMKgIMKgIMKgMSDCoCDCoCDCoDEgwqAgwqAgwqAxIMKgIMKgIMKg
MCA8YnI+Tm9kZSDCoCDCoDAsIHpvbmUgwqAgwqAgwqBETUEsIHR5cGUgwqAgSGlnaEF0b21pYyDC
oCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKg
MCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKg
IMKgMCDCoCDCoCDCoDAgPGJyPk5vZGUgwqAgwqAwLCB6b25lIMKgIMKgIMKgRE1BLCB0eXBlIMKg
IMKgIMKgIMKgIMKgQ01BIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDC
oCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKg
MCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCA8YnI+Tm9kZSDCoCDCoDAsIHpvbmUgwqAg
wqAgwqBETUEsIHR5cGUgwqAgwqAgwqBJc29sYXRlIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAg
wqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAg
wqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCA8YnI+Tm9kZSDC
oCDCoDAsIHpvbmUgwqBIaWdoTWVtLCB0eXBlIMKgIMKgVW5tb3ZhYmxlIMKgIMKgIDU1IMKgIMKg
IDQ3IMKgIMKgIDE2IMKgIMKgIMKgOCDCoCDCoCDCoDYgwqAgwqAgwqAyIMKgIMKgIMKgMSDCoCDC
oCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAxIMKgIMKgIMKgMCA8
YnI+Tm9kZSDCoCDCoDAsIHpvbmUgwqBIaWdoTWVtLCB0eXBlIMKgIMKgIMKgTW92YWJsZSDCoCDC
oCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDC
oCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKg
MCDCoCDCoCDCoDAgPGJyPk5vZGUgwqAgwqAwLCB6b25lIMKgSGlnaE1lbSwgdHlwZSDCoFJlY2xh
aW1hYmxlIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAg
wqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDC
oDAgwqAgwqAgwqAwIMKgIMKgIMKgMCA8YnI+Tm9kZSDCoCDCoDAsIHpvbmUgwqBIaWdoTWVtLCB0
eXBlIMKgIEhpZ2hBdG9taWMgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAw
IMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAg
wqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIDxicj5Ob2RlIMKgIMKgMCwgem9uZSDC
oEhpZ2hNZW0sIHR5cGUgwqAgwqAgwqAgwqAgwqBDTUEgwqAgwqAyNjEgwqAgwqA5MTUgwqAgwqA3
NzggwqAgwqAyMDQgwqAgwqAgNDggwqAgwqAgMjAgwqAgwqAgwqA1IMKgIMKgIMKgMCDCoCDCoCDC
oDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDEgwqAgwqAgMTMgPGJyPk5vZGUgwqAgwqAw
LCB6b25lIMKgSGlnaE1lbSwgdHlwZSDCoCDCoCDCoElzb2xhdGUgwqAgwqAgwqAwIMKgIMKgIMKg
MCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKg
IMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIMKgIMKgIMKgMCDCoCDCoCDCoDAgwqAgwqAgwqAwIDxi
cj48YnI+PGJyPk51bWJlciBvZiBibG9ja3MgdHlwZSDCoCDCoCBVbm1vdmFibGUgwqAgwqAgwqBN
b3ZhYmxlIMKgUmVjbGFpbWFibGUgwqAgSGlnaEF0b21pYyDCoCDCoCDCoCDCoCDCoENNQSDCoCDC
oCDCoElzb2xhdGUgPGJyPjxicj5Ob2RlIDAsIHpvbmUgwqAgwqAgwqBETUEgwqAgwqAgwqAgwqAg
wqAgMTAgwqAgwqAgwqAgwqAgwqAgMTQgwqAgwqAgwqAgwqAgwqAgwqA0IMKgIMKgIMKgIMKgIMKg
IMKgMCDCoCDCoCDCoCDCoCDCoCDCoDAgwqAgwqAgwqAgwqAgwqAgwqAwIMKgIMKgIDxicj5Ob2Rl
IDAsIHpvbmUgwqBIaWdoTWVtIMKgIMKgIMKgIMKgIMKgIMKgMyDCoCDCoCDCoCDCoCDCoCAzMiDC
oCDCoCDCoCDCoCDCoCDCoDAgwqAgwqAgwqAgwqAgwqAgwqAwIMKgIMKgIMKgIMKgIMKgIDU3IMKg
IMKgIMKgIMKgIMKgIMKgMMKgPGRpdj48YnI+PC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj5SZWdh
cmRzLDwvZGl2PjxkaXY+UGFua2FqPGJyPjxicj48L2Rpdj48L2Rpdj48L2Rpdj4NCg==
--0000000000000be3ff0590a36bae--

