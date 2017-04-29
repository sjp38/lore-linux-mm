Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B56E86B02E1
	for <linux-mm@kvack.org>; Sat, 29 Apr 2017 06:17:30 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u5so4522466wmg.13
        for <linux-mm@kvack.org>; Sat, 29 Apr 2017 03:17:30 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id f17si10323446wra.256.2017.04.29.03.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Apr 2017 03:17:29 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id r190so65689234wme.1
        for <linux-mm@kvack.org>; Sat, 29 Apr 2017 03:17:28 -0700 (PDT)
Date: Sat, 29 Apr 2017 13:17:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] mm, zone_device: replace {get,
 put}_zone_device_page() with a single reference
Message-ID: <20170429101726.cdczojcjjupb7myy@node.shutemov.name>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com>
 <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
 <1743017574.4309811.1493400875692.JavaMail.zimbra@redhat.com>
 <CAPcyv4jCfMwthPwbE-iuvef1KkMYUtA=qAydgfJzH0_otXoAOg@mail.gmail.com>
 <1579714997.4315035.1493402406629.JavaMail.zimbra@redhat.com>
 <CAPcyv4hvBKG8t3e3QvUnmkaopeM8eTniz5JPVkrZ5Puu5eaViw@mail.gmail.com>
 <1295710462.4327805.1493406971970.JavaMail.zimbra@redhat.com>
 <CAPcyv4i+iPm=hBviOYABaroz_JJYVy8Qja8Ka=-_uAQNnGjpeg@mail.gmail.com>
 <20170428193305.GA3912@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170428193305.GA3912@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

On Fri, Apr 28, 2017 at 03:33:07PM -0400, Jerome Glisse wrote:
> On Fri, Apr 28, 2017 at 12:22:24PM -0700, Dan Williams wrote:
> > Are you sure about needing to hook the 2 -> 1 transition? Could we
> > change ZONE_DEVICE pages to not have an elevated reference count when
> > they are created so you can keep the HMM references out of the mm hot
> > path?
> 
> 100% sure on that :) I need to callback into driver for 2->1 transition
> no way around that. If we change ZONE_DEVICE to not have an elevated
> reference count that you need to make a lot more change to mm so that
> ZONE_DEVICE is never use as fallback for memory allocation. Also need
> to make change to be sure that ZONE_DEVICE page never endup in one of
> the path that try to put them back on lru. There is a lot of place that
> would need to be updated and it would be highly intrusive and add a
> lot of special cases to other hot code path.

Could you explain more on where the requirement comes from or point me to
where I can read about this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
