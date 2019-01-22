Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 792CE8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 12:29:48 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so9789195edd.2
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 09:29:48 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5-v6si2047551ejb.255.2019.01.22.09.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 09:29:47 -0800 (PST)
Date: Tue, 22 Jan 2019 18:29:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: no need to check return value of debugfs_create
 functions
Message-ID: <20190122172944.GL4087@dhcp22.suse.cz>
References: <20190122152151.16139-14-gregkh@linuxfoundation.org>
 <20190122153102.GJ4087@dhcp22.suse.cz>
 <20190122155255.GA20142@kroah.com>
 <20190122160701.GK4087@dhcp22.suse.cz>
 <20190122162749.GA22841@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190122162749.GA22841@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org

On Tue 22-01-19 17:27:49, Greg KH wrote:
> On Tue, Jan 22, 2019 at 05:07:01PM +0100, Michal Hocko wrote:
[...]
> > sounds like a poor design goal to me but not mine code to maintain so...
> 
> The design goal was to make it as simple as possible to use, and that
> includes "you do not care about the return value".  Now we do have to
> return a value because some people need that for when they want to make
> a subdirectory, or remove the file later on, otherwise I would have just
> had everything be a void return function :)

I suspect that you are making assumptions which might change in the
future and this whole mess will be unfixable. But whatever I do not care
about debugfs at all.
-- 
Michal Hocko
SUSE Labs
