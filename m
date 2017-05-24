Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id DAD836B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 12:06:33 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id k4so48603188uaa.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 09:06:33 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id d28si11510881uah.111.2017.05.24.09.06.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 09:06:32 -0700 (PDT)
Date: Wed, 24 May 2017 11:03:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/6] refine and rename slub sysfs
In-Reply-To: <20170524152124.GB8445@WeideMacBook-Pro.local>
Message-ID: <alpine.DEB.2.20.1705241101090.24771@east.gentwo.org>
References: <20170517141146.11063-1-richard.weiyang@gmail.com> <20170518090636.GA25471@dhcp22.suse.cz> <20170523032705.GA4275@WeideMBP.lan> <20170523063911.GC12813@dhcp22.suse.cz> <20170524095450.GA7706@WeideMBP.lan> <20170524120318.GE14733@dhcp22.suse.cz>
 <20170524152124.GB8445@WeideMacBook-Pro.local>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 24 May 2017, Wei Yang wrote:

> >
> >Who is going to use those new entries and for what purpose? Why do we
> >want to expose even more details of the slab allocator to the userspace.
> >Is the missing information something fundamental that some user space
> >cannot work without it? Seriously these are essential questions you
> >should have answer for _before_ posting the patch and mention all those
> >reasons in the changelog.
>
> It is me who wants to get more details of the slub behavior.
> AFAIK, no one else is expecting this.

I would appreciate some clearer structured statistics. These are important
for diagnostics and for debugging. Do not go overboard with this. Respin
it and provide also a cleanup of the slabinfo tool? I would appreciate it.

> Hmm, if we really don't want to export these entries, why not remove related
> code? Looks we are sure they will not be touched.

Please have a look at the slabinfo code which depends on those fields in
order to display slab information. I have patchsets here that will add
more functionality to slab and those will also add additional fields to
sysfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
