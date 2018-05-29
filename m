Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA3F46B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 08:12:48 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o19-v6so877246pgn.14
        for <linux-mm@kvack.org>; Tue, 29 May 2018 05:12:48 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id 30-v6si32631415plb.531.2018.05.29.05.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 05:12:47 -0700 (PDT)
Date: Tue, 29 May 2018 06:12:44 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] docs/vm: move ksm and transhuge from "user" to
 "internals" section.
Message-ID: <20180529061244.348b6291@lwn.net>
In-Reply-To: <1527588818-7031-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1527588818-7031-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org

On Tue, 29 May 2018 13:13:38 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> After the userspace interface description for KSM and THP was split to
> Documentation/admin-guide/mm, the remaining parts belong to the section
> describing MM internals.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Applied, thanks.

jon
