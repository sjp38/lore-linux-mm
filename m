Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEC15440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:12:10 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id n42so27484523qtn.10
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 13:12:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j31si5736208qtb.341.2017.07.13.13.12.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 13:12:09 -0700 (PDT)
Date: Thu, 13 Jul 2017 16:12:05 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/5] Cache coherent device memory (CDM) with HMM v4
Message-ID: <20170713201205.GA1979@redhat.com>
References: <20170712180607.2885-1-jglisse@redhat.com>
 <20170713163228.5b49eea9@firefly.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170713163228.5b49eea9@firefly.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>

On Thu, Jul 13, 2017 at 04:32:28PM +1000, Balbir Singh wrote:
> On Wed, 12 Jul 2017 14:06:02 -0400
> Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > Changes since v3:
> >   - change name to device host (s/DEVICE_PUBLIC/DEVICE_HOST/)
> 
> I think you've mis-interpreted what Dan said
> 
> The message @
> http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1441839.html
> states
> 
> "I was suggesting MEMORY_DEVICE_HOST for persistent memory and
> MEMORY_DEVICE_PUBLIC as you want for CDM."

Oh i missed that email :( is was lost in long spam thread in my inbox.
Well i will likely repost a new version of HMM-CDM and with updated
name then.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
