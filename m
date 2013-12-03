Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f205.google.com (mail-ve0-f205.google.com [209.85.128.205])
	by kanga.kvack.org (Postfix) with ESMTP id 357656B0035
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 15:09:35 -0500 (EST)
Received: by mail-ve0-f205.google.com with SMTP id oz11so154923veb.0
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 12:09:34 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id hb3si51232553pac.297.2013.12.03.04.44.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Dec 2013 04:44:35 -0800 (PST)
Message-ID: <529DD22F.3040102@iki.fi>
Date: Tue, 03 Dec 2013 14:44:31 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: Slab BUG with DEBUG_* options
References: <alpine.SOC.1.00.1311300125490.6363@math.ut.ee>	<529DC632.9010107@iki.fi> <CAAmzW4N=2--OuOFVEME3FJa7uFCkVEYJp=9DbSBVOPjiXnLxcg@mail.gmail.com>
In-Reply-To: <CAAmzW4N=2--OuOFVEME3FJa7uFCkVEYJp=9DbSBVOPjiXnLxcg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Meelis Roos <mroos@linux.ee>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 12/03/2013 02:25 PM, Joonsoo Kim wrote:
> No. He report that BUG() is triggered on v3.11-rc2 and v3.12.
> And my recent change is merged into v3.13-rc1 as you know. :)

Hah, I guess my eyesight isn't what it used to be, I could have sworn it 
said v3.13-rc2... Thanks anyway, Joonsoo!

                             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
