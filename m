Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 99C886B0266
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:34:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v10-v6so8808707pfm.11
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 07:34:22 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id e72-v6si1790824pfd.352.2018.06.26.07.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 07:34:21 -0700 (PDT)
Date: Tue, 26 Jun 2018 08:34:19 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] doc: add description to dirtytime_expire_seconds
Message-ID: <20180626083419.7f129fe1@lwn.net>
In-Reply-To: <1527724613-17768-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1527724613-17768-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: tytso@mit.edu, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 31 May 2018 07:56:53 +0800
Yang Shi <yang.shi@linux.alibaba.com> wrote:

> commit 1efff914afac8a965ad63817ecf8861a927c2ace ("fs: add
> dirtytime_expire_seconds sysctl") introduced dirtytime_expire_seconds
> knob, but there is not description about it in
> Documentation/sysctl/vm.txt.
> 
> Add the description for it.

Applied to the docs tree, sorry for taking so long to get to it.

Thanks,

jon
