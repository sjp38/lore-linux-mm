Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6316B0038
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 15:53:57 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id d9so101065652itc.4
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 12:53:57 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id k15si1324084itk.15.2017.01.14.12.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 12:53:56 -0800 (PST)
Date: Sat, 14 Jan 2017 14:53:54 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Trace free objects at KERN_INFO
In-Reply-To: <20170113154850.518-1-daniel.thompson@linaro.org>
Message-ID: <alpine.DEB.2.20.1701141453190.692@east.gentwo.org>
References: <20170113154850.518-1-daniel.thompson@linaro.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Thompson <daniel.thompson@linaro.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org


Acked-by: Christoph Lameter <cl@linux.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
