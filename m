Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C41976B751E
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 10:57:46 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so10098918edb.1
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 07:57:46 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 05 Dec 2018 16:57:44 +0100
From: osalvador@suse.de
Subject: Re: [PATCH v1] drivers/base/memory.c: Use DEVICE_ATTR_RO and friends
In-Reply-To: <20181203111611.10633-1-david@redhat.com>
References: <20181203111611.10633-1-david@redhat.com>
Message-ID: <b2f49f4c1ffae88af2d2829b4ee43905@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@kernel.org>, Wei Yang <richard.weiyang@gmail.com>, owner-linux-mm@kvack.org

On 2018-12-03 12:16, David Hildenbrand wrote:
> Let's use the easier to read (and not mess up) variants:
> - Use DEVICE_ATTR_RO
> - Use DEVICE_ATTR_WO
> - Use DEVICE_ATTR_RW
> instead of the more generic DEVICE_ATTR() we're using right now.
> 
> We have to rename most callback functions. By fixing the intendations 
> we
> can even save some LOCs.
> 
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks
