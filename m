Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2CFE66B0009
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 09:53:10 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m37so8998809iti.9
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 06:53:10 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id n62si2468631ioe.46.2018.03.12.06.53.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 06:53:09 -0700 (PDT)
Date: Mon, 12 Mar 2018 08:53:07 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab.c: remove duplicated check of colour_next
In-Reply-To: <877eqilr71.fsf@gmail.com>
Message-ID: <alpine.DEB.2.20.1803120852490.1262@nuc-kabylake>
References: <877eqilr71.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Lakeev <sunnyddayss@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Acked-by: Christoph Lameter <cl@linux.com>
