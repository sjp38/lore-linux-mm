Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8C76B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 12:48:07 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hm5so83180547pac.4
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 09:48:07 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id 128si11748033pgc.326.2016.10.13.09.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 09:48:06 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id 128so37711411pfz.0
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 09:48:06 -0700 (PDT)
Date: Thu, 13 Oct 2016 18:47:58 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCHv4 0/3] z3fold: add shrinker
Message-Id: <20161013184758.9ecfd318fa542e14e2d2c5b1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>


This patch set implements shrinker for z3fold. The actual shrinker
implementation will follow some code optimizations and preparations
that I thought would be reasonable to have as separate patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
