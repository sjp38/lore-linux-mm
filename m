Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7106B7B12
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 12:20:09 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id g188so613600pgc.22
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 09:20:09 -0800 (PST)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id o9si743634pfe.63.2018.12.06.09.20.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 09:20:08 -0800 (PST)
Date: Thu, 6 Dec 2018 10:20:01 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] docs/core-api: make mm-api.rst more structured
Message-ID: <20181206102001.7f6d0a00@lwn.net>
In-Reply-To: <1543416344-25543-1-git-send-email-rppt@linux.ibm.com>
References: <1543416344-25543-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org

On Wed, 28 Nov 2018 16:45:44 +0200
Mike Rapoport <rppt@linux.ibm.com> wrote:

> The mm-api.rst covers variety of memory management APIs under "More Memory
> Management Functions" section. The descriptions included there are in a
> random order there are quite a few of them which makes the section too
> long.
> 
> Regrouping the documentation by subject and splitting the long "More Memory
> Management Functions" section into several smaller sections makes the
> generated html more usable.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Applied, thanks.

jon
