Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40AA46B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 19:07:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q15so2654986pff.15
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 16:07:33 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id l15-v6si2047341pgn.414.2018.04.27.16.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 16:07:31 -0700 (PDT)
Date: Fri, 27 Apr 2018 17:07:29 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 0/7]  docs/vm: start moving files do
 Documentation/admin-guide`
Message-ID: <20180427170729.1d8e4123@lwn.net>
In-Reply-To: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@infradead.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 18 Apr 2018 11:07:43 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> These pacthes begin categorizing memory management documentation.  The
> documents that describe userspace APIs and do not overload the reader with
> implementation details can be moved to Documentation/admin-guide, so let's
> do it :)

Looks good, set applied, thanks.

jon
