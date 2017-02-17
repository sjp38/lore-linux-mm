Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A10D6B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 15:39:36 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v77so3552811wmv.5
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:39:36 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id 1si14571062wre.62.2017.02.17.12.39.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 12:39:35 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id r141so18209812wmg.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:39:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170217154419.xr4n2ikp4li3c7co@lukather>
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
 <CACvgo51p+aqegjkbF6jGggwr+KXq_71w0VFzJvFAF6_egT1-kA@mail.gmail.com> <20170217154419.xr4n2ikp4li3c7co@lukather>
From: Emil Velikov <emil.l.velikov@gmail.com>
Date: Fri, 17 Feb 2017 20:39:33 +0000
Message-ID: <CACvgo51vLca_Ji8VQBO5fqCrbhpm_=6mrqx1K-7GddVv5yMKWg@mail.gmail.com>
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>, ML dri-devel <dri-devel@lists.freedesktop.org>, Mark Rutland <mark.rutland@arm.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, devicetree <devicetree@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Chen-Yu Tsai <wens@csie.org>, Rob Herring <robh+dt@kernel.org>, LAKML <linux-arm-kernel@lists.infradead.org>

Hi Maxime,

As I feared things have taken a turn for the bitter end :-]

It seems that this is a heated topic, so I'l kindly ask that we try
the following:

 - For people such as myself/Tobias/others who feel that driver and DT
bindings should go hand in hand, prove them wrong.
But please, do so by pointing to the documentation (conclusion of a
previous discussion). This way you don't have to repeat yourself and
get [too] annoyed over silly suggestions.

 - The series has code changes which [seemingly] cater for out of tree
module(s).
Clearly state in the commit message who is the user, why it's save to
do so and get an Ack from more prominent [DRM] developers.

Please try to understand that I do not want to annoy/agitate you, I'm
merely pointing what seems [to me] as incorrect.
Nobody is perfect, so if I/others are wrong do point me/us to a
reading to educate ourselves.

Thanks
Emil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
