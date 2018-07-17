Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D18396B000E
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 19:31:10 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o6-v6so2003765qtp.15
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 16:31:10 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i65-v6si1025544qkd.91.2018.07.17.16.31.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 16:31:05 -0700 (PDT)
Date: Wed, 18 Jul 2018 07:31:00 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] mm/page_alloc: Deprecate kernelcore=nn and movable_core=
Message-ID: <20180717233100.GH1724@MiWiFi-R3L-srv>
References: <20180717131837.18411-1-bhe@redhat.com>
 <alpine.DEB.2.21.1807171344320.12251@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807171344320.12251@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, corbet@lwn.net, linux-doc@vger.kernel.org

On 07/17/18 at 01:46pm, David Rientjes wrote:
> On Tue, 17 Jul 2018, Baoquan He wrote:
> 
> > We can still use 'kernelcore=mirror' or 'movable_node' for the usage
> > of hotplug and movable zone. If somebody shows up with a valid usecase
> > we can reconsider.
> > 
> 
> We actively use kernelcore=n%, I had recently added support for the option 
> in the first place in 4.17.  It's certainly not deprecated.

Thanks for telling. Just for curiosity, could you tell the scenario you
are using kernelcore=n%? Since it evenly spread movable area on nodes,
we may not be able to physically hot unplug/plug RAM.

Thanks
Baoquan
