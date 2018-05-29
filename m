Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 161696B0007
	for <linux-mm@kvack.org>; Tue, 29 May 2018 08:21:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o19-v6so884568pgn.14
        for <linux-mm@kvack.org>; Tue, 29 May 2018 05:21:35 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id 4-v6si32284166pfb.204.2018.05.29.05.21.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 05:21:34 -0700 (PDT)
Date: Tue, 29 May 2018 06:21:31 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] docs/admin-guide/mm: add high level concepts overview
Message-ID: <20180529062131.545d4e34@lwn.net>
In-Reply-To: <20180529113725.GB13092@rapoport-lnx>
References: <20180529113725.GB13092@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 29 May 2018 14:37:25 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> The are terms that seem obvious to the mm developers, but may be somewhat
> obscure for, say, less involved readers.
> 
> The concepts overview can be seen as an "extended glossary" that introduces
> such terms to the readers of the kernel documentation.

So as I read through this I thought of all kinds of ways it could be
improved, but I suspect that will always be the case.  It's a good intro
as-is, so I've applied it.  Thanks!

jon
