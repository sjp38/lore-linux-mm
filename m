Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 321356B0253
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 20:49:23 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so313931683pfb.7
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 17:49:23 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id p15si26658796pgg.270.2017.01.17.17.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 17:49:22 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id e4so27903577pfg.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 17:49:22 -0800 (PST)
Date: Tue, 17 Jan 2017 17:49:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: Trace free objects at KERN_INFO
In-Reply-To: <20170113154850.518-1-daniel.thompson@linaro.org>
Message-ID: <alpine.DEB.2.10.1701171749090.119060@chino.kir.corp.google.com>
References: <20170113154850.518-1-daniel.thompson@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Thompson <daniel.thompson@linaro.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org

On Fri, 13 Jan 2017, Daniel Thompson wrote:

> Currently when trace is enabled (e.g. slub_debug=T,kmalloc-128 ) the
> trace messages are mostly output at KERN_INFO. However the trace code
> also calls print_section() to hexdump the head of a free object. This
> is hard coded to use KERN_ERR, meaning the console is deluged with
> trace messages even if we've asked for quiet.
> 
> Fix this the obvious way but adding a level parameter to
> print_section(), allowing calls from the trace code to use the same
> trace level as other trace messages.
> 
> Signed-off-by: Daniel Thompson <daniel.thompson@linaro.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
