Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6014C6B0007
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 19:25:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r63so910407pfl.12
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 16:25:26 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id w130si2200996pfd.169.2018.04.27.16.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 16:25:25 -0700 (PDT)
Date: Fri, 27 Apr 2018 17:25:23 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 0/7] docs/vm: update KSM documentation
Message-ID: <20180427172523.746d2ffd@lwn.net>
In-Reply-To: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Tue, 24 Apr 2018 09:40:21 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> These patches extend KSM documentation with high level design overview and
> some details about reverse mappings and split the userspace interface
> description to Documentation/admin-guide/mm.
> 
> The description of some KSM sysfs attributes is changed so that it won't
> include implementation detail. The description of these implementation
> details are moved to the new "Design" section.
> 
> The last patch in the series depends on the patchset that create
> Documentation/admin-guide/mm [1], all the rest applies cleanly to the
> current docs-next.

I've applied the set, thanks.

jon
