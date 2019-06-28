Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5222CC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 00:46:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB15C2086D
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 00:46:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="Bf889EkY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB15C2086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4815C6B0005; Thu, 27 Jun 2019 20:46:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 432698E0003; Thu, 27 Jun 2019 20:46:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 321198E0002; Thu, 27 Jun 2019 20:46:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 10E246B0005
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 20:46:52 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b63so5593460ywc.12
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 17:46:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=u5QIn4e25W/XymTgpUSyhezMLD/1zuXkNA9riAdb3fc=;
        b=VYtuYV9323IEnPbpKcJZt+wKEp5iN6/IMLdYA5ZwJ55AnBaZYO9w30J4EWzouos6NW
         o4sH40135f06XAr0TtDWOH2RGrSr1t77F/8ucvYAc7zqoq03R7vrnSXU+UhNF1LGeIoV
         jMOUi1VVR8r+CexujhoONnlrYuDprAUHyr9ILvlrQ3O10ha+ehlz0tL3HY59ujxcnwlI
         589tkpdpwF+LXDpoALYE1Oi+yinOgJq56s0xyosT9V0Iki/y0R2oFr0IhpeQ7Dh1M1ZH
         99DoX3RKmAYo2kB7V9tJfCM5OfFr05iXOOrnxI54/fd42e9q9LSVUn6mffV6XH5Wi6MV
         p/Sg==
X-Gm-Message-State: APjAAAWLVpfi+dRJnFD9ojJscM/FqRLhhHdamLsi41pBMGZWleZB71NI
	IjsEX9Z0AOUAESnD+MmpIRy5GyssfgKeeNXrRYuwM4Ee5/vIVQ4TLoUcrNNiaaQKw9mt1jhqtrI
	YEddQgeFpATz0w9kazYoclaIGBEwXHv5ZZY+W/rXfa+ytZQWSU1N/PdH3UQH4zzrzOA==
X-Received: by 2002:a25:bb84:: with SMTP id y4mr4486870ybg.484.1561682811717;
        Thu, 27 Jun 2019 17:46:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznUCg9vs9f4+mxKBfAa6PNAjxjgmZT6xbLmswarrjp97snDRwkey+GOXegLkqK7vhTKj7i
X-Received: by 2002:a25:bb84:: with SMTP id y4mr4486842ybg.484.1561682810809;
        Thu, 27 Jun 2019 17:46:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561682810; cv=none;
        d=google.com; s=arc-20160816;
        b=GLSlcy7k1+GwgVP5nvlHD8aiii1vtEleXi0Zeo+oHQ/GjrWwvnh0cGwOpulzKhYv2i
         VxiJsquce3vxiHGyH+OeOZUreTnI0kMydDAV5+Q4Ba8R+XOYAsa7I5hWhFsxuROWtx0V
         di+LPUYXEwih4paKHAQ1qBjZ3n/TyGIWv0Ycbg/LlrZwis1CExdReHxlKRLuFIz/s9AD
         u7ROVpixWxLdUN2DcsvzXDskDLyAcNeikLY/4K27yLAcSKyqwNuqvqvFqwKWLf3Q3+t1
         k2lAalkbc/pJfqXKvz+Vm5oIYmwhABPNlk8FCjOOshDNuabgVd7syxOImbUCT/LXsI+r
         +IMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=u5QIn4e25W/XymTgpUSyhezMLD/1zuXkNA9riAdb3fc=;
        b=O+65kFVPlhjRs3OPqTFVR5JqE9AwW2iByLofvvk0Gbsrn13HGuLP9b/mkY6I3nv0hX
         34hZTtwyu5fflxMlHN8Bi9g5TOiuMyY6VOKK7fE8Thbd7xexd2wpBK7KPzLQ6l1Fhuq8
         Ql6lqWEp+GHTEWgMeJzw7xhCC9P55cgs7/snuX8VreWxQy5V8gWnjXAGxJqQxJwFoc6E
         oAXHTLvJC0zITbAoYU7UlNrBhd9oPr0fOSR7CUnaOD4e4yptLZoIi7ydq7CS9CxAlAri
         /RSZkq7hbAZ/n9H5brzIhaf7Gp9VpQ0IuBECCpU9uC/DCjUqFojUteBtCoehUGnXpfIh
         7P3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=Bf889EkY;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com. [66.55.73.32])
        by mx.google.com with ESMTP id f188si409182ybg.19.2019.06.27.17.46.50
        for <linux-mm@kvack.org>;
        Thu, 27 Jun 2019 17:46:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) client-ip=66.55.73.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=Bf889EkY;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id D2A782DC0032;
	Thu, 27 Jun 2019 20:46:49 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1561682810;
	bh=UhW8aV9JrdJrV6DY1cn+26607uxAHeKKSDkYSCJIz2M=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=Bf889EkYMaeNluUjhKxTar/zrDWtyG6z4MPIgQbMM1hlBS3knrgi5bTM8SXlXknuf
	 V6ubG90eRxu9h07jXXMnZJorUJrKXQjE2E7s5j0FewNgumQlepxJb5NZVPsdPc+AOA
	 9Pj2jJffN6tZ4FlLq1IGlIAvGgktDs1tW84J9ZVKmlur+850hOTKPGNjBgFOa7NpEd
	 lrAoZFoig0zuD0+uai9JHtm00vwzl83aiAWpMyvoYoymkm1IZyq3oZ9lu4z9Xb5lNz
	 inOieRfjfotmRvlxvbPgmQmAPaZX9QNe/uLjKV0MhXwmnAJwy/f217xz6G1vxiPcy/
	 7ItzyL/DSdZJe0gofc6J9n/BFBb18P8NglNk+B55nwdn4KzgHIEA3sHoG3wynJ53KZ
	 94cqC2Ani2ar+hIbnXdcBpKrat9bJUCpkzwdVO8v95czBy26uqFRSa8tISVw+Q934m
	 ac4o6vS2yJTFf9Quc1UYkXXd1bEJ/5yBu+vMghCf1s8RsZQaLL2eXRJudkZWP/mMI1
	 BzQHnbBrxRQivmnKZc03+cxY5jiyTcUwQejTVSo5W2VayozVUy23nsKdIi+XgEgjbn
	 xDx1+ZdkXwzOCfEdJ7Nrd7eAutlmBMC08PlSwG2sS0aEN9fr1wqFnHEUvd6LcQb9m5
	 j7IIohidJfKiyX+lq2oOy0tU=
Received: from adsilva.ozlabs.ibm.com (static-82-10.transact.net.au [122.99.82.10] (may be forged))
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x5S0kS8t045453
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NO);
	Fri, 28 Jun 2019 10:46:44 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
Message-ID: <833b9675bc363342827cb8f7c76ebb911f7f960d.camel@d-silva.org>
Subject: Re: [PATCH v2 1/3] mm: Trigger bug on if a section is not found in
 __section_nr
From: "Alastair D'Silva" <alastair@d-silva.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki"
 <rafael@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pavel
 Tatashin <pasha.tatashin@oracle.com>,
        Oscar Salvador <osalvador@suse.de>, Mike Rapoport <rppt@linux.ibm.com>,
        Baoquan He <bhe@redhat.com>, Wei Yang
 <richard.weiyang@gmail.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Date: Fri, 28 Jun 2019 10:46:28 +1000
In-Reply-To: <20190627080724.GK17798@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
	 <20190626061124.16013-2-alastair@au1.ibm.com>
	 <20190626062113.GF17798@dhcp22.suse.cz>
	 <d4af66721ea53ce7df2d45a567d17a30575672b2.camel@d-silva.org>
	 <20190626065751.GK17798@dhcp22.suse.cz>
	 <e66e43b1fdfbff94ab23a23c48aa6cbe210a3131.camel@d-silva.org>
	 <20190627080724.GK17798@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.2 (3.32.2-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Fri, 28 Jun 2019 10:46:45 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-06-27 at 10:10 +0200, Michal Hocko wrote:
> On Thu 27-06-19 10:50:57, Alastair D'Silva wrote:
> > On Wed, 2019-06-26 at 08:57 +0200, Michal Hocko wrote:
> > > On Wed 26-06-19 16:27:30, Alastair D'Silva wrote:
> > > > On Wed, 2019-06-26 at 08:21 +0200, Michal Hocko wrote:
> > > > > On Wed 26-06-19 16:11:21, Alastair D'Silva wrote:
> > > > > > From: Alastair D'Silva <alastair@d-silva.org>
> > > > > > 
> > > > > > If a memory section comes in where the physical address is
> > > > > > greater
> > > > > > than
> > > > > > that which is managed by the kernel, this function would
> > > > > > not
> > > > > > trigger the
> > > > > > bug and instead return a bogus section number.
> > > > > > 
> > > > > > This patch tracks whether the section was actually found,
> > > > > > and
> > > > > > triggers the
> > > > > > bug if not.
> > > > > 
> > > > > Why do we want/need that? In other words the changelog should
> > > > > contina
> > > > > WHY and WHAT. This one contains only the later one.
> > > > >  
> > > > 
> > > > Thanks, I'll update the comment.
> > > > 
> > > > During driver development, I tried adding peristent memory at a
> > > > memory
> > > > address that exceeded the maximum permissable address for the
> > > > platform.
> > > > 
> > > > This caused __section_nr to silently return bogus section
> > > > numbers,
> > > > rather than complaining.
> > > 
> > > OK, I see, but is an additional code worth it for the non-
> > > development
> > > case? I mean why should we be testing for something that
> > > shouldn't
> > > happen normally? Is it too easy to get things wrong or what is
> > > the
> > > underlying reason to change it now?
> > > 
> > 
> > It took me a while to identify what the problem was - having the
> > BUG_ON
> > would have saved me a few hours.
> > 
> > I'm happy to just have the BUG_ON 'nd drop the new error return (I
> > added that in response to Mike Rapoport's comment that the original
> > patch would still return a bogus section number).
> 
> Well, BUG_ON is about the worst way to handle an incorrect input. You
> really do not want to put a production environment down just because
> there is a bug in a driver, right? There are still many {VM_}BUG_ONs
> in the tree and there is a general trend to get rid of many of them
> rather than adding new ones.
> 
> Now back to your patch. You are adding an error handling where we
> simply
> do not expect invalid data. This is often the case for the core
> kernel
> functionality because we do expect consumers of the code to do the
> right
> thing. E.g. __section_nr already takes a pointer to struct section
> which
> assumes that this core data structure is already valid. Adding a
> check
> here adds an unnecessary overhead so this doesn't really sound like a
> good idea to me.


Thanks for providing a good explanation.

In this situation, since we return a bogus section number, we get
crashes elsewhere in the kernel if the code rumbles on.

Given that there is already a VM_BUG_ON in the code, how do you feel
about broadening the scope from 'VM_BUG_ON(!root)' to 'VM_BUG_ON(!root
|| (root_nr == NR_SECTION_ROOTS))'?

-- 
Alastair D'Silva           mob: 0423 762 819
skype: alastair_dsilva    
Twitter: @EvilDeece
blog: http://alastair.d-silva.org


