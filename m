Received: by zproxy.gmail.com with SMTP id k1so211645nzf
        for <linux-mm@kvack.org>; Sun, 02 Oct 2005 22:40:11 -0700 (PDT)
Message-ID: <aec7e5c30510022240p1a7e7189gf2b72c209c76b5ee@mail.gmail.com>
Date: Mon, 3 Oct 2005 14:40:09 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 2/2] memhotplug testing: enable sparsemem on flat systems
In-Reply-To: <20050930152532.9FDF34BD@kernel.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20050930152531.3FDB46D3@kernel.beaverton.ibm.com>
	 <20050930152532.9FDF34BD@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: magnus@valinux.co.jp, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi again,

I've tested this patch together with the "hack for flat
systems"-patch, and they seem to work correctly both configured as
single-node sparsemem PC and configured as emulated NUMA system
together with the NUMA emulation patches.

So these patches replace my patch "[PATCH 05/07] i386: sparsemem on pc".

Thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
