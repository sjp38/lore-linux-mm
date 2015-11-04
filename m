Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id F107882F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 08:35:43 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so53649777pab.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 05:35:43 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id xw4si2269394pac.34.2015.11.04.05.35.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 05:35:43 -0800 (PST)
Received: by padhx2 with SMTP id hx2so45631091pad.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 05:35:43 -0800 (PST)
Subject: Re: [PATCH v6 2/3] percpu: add PERCPU_ATOM_SIZE for a generic percpu area setup
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <5638F5B9.3040404@arm.com>
Date: Wed, 4 Nov 2015 22:35:36 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <CC50E962-D166-44EB-A610-6F70A5234802@gmail.com>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com> <1446363977-23656-3-git-send-email-jungseoklee85@gmail.com> <alpine.DEB.2.20.1511021008580.27740@east.gentwo.org> <20151102162236.GB7637@e104818-lin.cambridge.arm.com> <F4C06691-60EF-45FA-9AD7-9FBF8F1960AB@gmail.com> <5638F5B9.3040404@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>, mark.rutland@arm.com, takahiro.akashi@linaro.org, barami97@gmail.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, linux-arm-kernel@lists.infradead.org

On Nov 4, 2015, at 2:58 AM, James Morse wrote:
> Hi Jungseok,

Hi James,

> On 03/11/15 13:49, Jungseok Lee wrote:
>> Additionally, I've been thinking of do_softirq_own_stack() which is =
your
>> another comment [3]. Recently, I've realized there is possibility =
that
>> I misunderstood your intention. Did you mean that irq_handler hook is =
not
>> enough? Should do_softirq_own_stack() be implemented together?
>=20
> I've been putting together a version to illustrate this, I aim to post =
it
> before the end of this week=85

It sounds great! I will wait for your version.

Best Regards
Jungseok Lee=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
