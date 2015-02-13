Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 53FE26B0096
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 18:36:38 -0500 (EST)
Received: by iebtr6 with SMTP id tr6so12627979ieb.10
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 15:36:38 -0800 (PST)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com. [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id pk7si2508105igb.14.2015.02.13.15.36.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Feb 2015 15:36:37 -0800 (PST)
Received: by mail-ig0-f172.google.com with SMTP id l13so13746597iga.5
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 15:36:37 -0800 (PST)
Date: Fri, 13 Feb 2015 15:36:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm: slub: parse slub_debug O option in switch
 statement
In-Reply-To: <1423865980-10417-2-git-send-email-chris.j.arges@canonical.com>
Message-ID: <alpine.DEB.2.10.1502131536250.25326@chino.kir.corp.google.com>
References: <1423865980-10417-1-git-send-email-chris.j.arges@canonical.com> <1423865980-10417-2-git-send-email-chris.j.arges@canonical.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris J Arges <chris.j.arges@canonical.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, 13 Feb 2015, Chris J Arges wrote:

> By moving the O option detection into the switch statement, we allow this
> parameter to be combined with other options correctly. Previously options like
> slub_debug=OFZ would only detect the 'o' and use DEBUG_DEFAULT_FLAGS to fill
> in the rest of the flags.
> 
> Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
