Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B56396B0007
	for <linux-mm@kvack.org>; Mon, 21 May 2018 11:27:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e20-v6so9451016pff.14
        for <linux-mm@kvack.org>; Mon, 21 May 2018 08:27:44 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id z21-v6si13771218pfn.31.2018.05.21.08.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 08:27:43 -0700 (PDT)
Date: Mon, 21 May 2018 09:27:41 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 0/3] docs/vm: transhuge: split userspace bits to
 admin-guide/mm
Message-ID: <20180521092741.40f2cbd7@lwn.net>
In-Reply-To: <1526285620-453-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1526285620-453-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Mon, 14 May 2018 11:13:37 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> Here are minor updates to transparent hugepage docs. Except from minor
> formatting and spelling updates, these patches re-arrange the transhuge.rst
> so that userspace interface description will not be interleaved with the
> implementation details and it would be possible to split the userspace
> related bits to Documentation/admin-guide/mm, which is done by the third
> patch.

Looks good, I've applied the set, after adding a changelog for #3.

Thanks,

jon
