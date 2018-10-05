Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 61B4A6B000D
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 03:08:50 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z65-v6so10011891wrb.23
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 00:08:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10-v6sor5002565wri.48.2018.10.05.00.08.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 00:08:49 -0700 (PDT)
Date: Fri, 5 Oct 2018 09:08:47 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3 6/6] memory-hotplug.txt: Add some details about
 locking internals
Message-ID: <20181005070847.GB27754@techadventures.net>
References: <20180927092554.13567-1-david@redhat.com>
 <20180927092554.13567-7-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180927092554.13567-7-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Sep 27, 2018 at 11:25:54AM +0200, David Hildenbrand wrote:
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3
