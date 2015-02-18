Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 310CA6B00B2
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 17:18:19 -0500 (EST)
Received: by pdjy10 with SMTP id y10so4148965pdj.13
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 14:18:18 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ap9si4088261pad.73.2015.02.18.14.18.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Feb 2015 14:18:18 -0800 (PST)
Date: Wed, 18 Feb 2015 14:18:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 1/3] mm: cma: debugfs interface
Message-Id: <20150218141816.08b534623efc62a778c38d27@linux-foundation.org>
In-Reply-To: <1423780008-16727-2-git-send-email-sasha.levin@oracle.com>
References: <1423780008-16727-1-git-send-email-sasha.levin@oracle.com>
	<1423780008-16727-2-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, iamjoonsoo.kim@lge.com, m.szyprowski@samsung.com, lauraa@codeaurora.org, s.strogin@partner.samsung.com

On Thu, 12 Feb 2015 17:26:46 -0500 Sasha Levin <sasha.levin@oracle.com> wrote:

> Implement a simple debugfs interface to expose information about CMA areas
> in the system.

I'm not seeing any description of the proposed interface in changelog,
code comments or documentation.

- What files and directories are created?  Something like
  /debug/cma/cma-NN, where NN represents...  what?

- What are the debugfs file permissions?

- Example output along with any needed explanation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
