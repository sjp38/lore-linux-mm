Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B783C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:59:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 244032146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:59:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 244032146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4E9B6B0007; Wed, 20 Mar 2019 10:59:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD7C56B000A; Wed, 20 Mar 2019 10:59:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 979B36B000C; Wed, 20 Mar 2019 10:59:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BDEA6B0007
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:59:15 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id w134so21052011qka.6
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:59:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=8+NFEdA7eV6jKlnhbgsAvv8kVflCeDHgDx4zrDqFGI0=;
        b=FNZ10qu4bbW+KJ4Q6t39y3YM0YvdsUbtGxBisTokaQt7i4mcnUFoaLmzyho5ZhMqXd
         A12Nkap2FL2L1RARsuZT/YYbfrvX6KOS4tqo9xxQFvop43wwHmCz9vnOz8ZL5BhydU2d
         iEbRn/CGad5Dt1MemYZpRCUwn7sfbsEUi4PYFrnT4zJiX6JsydLpCJ8lnqrKMld0+HSA
         P2RNKa67gG1UxrP/nC6uLkccAGPWr+j8nCyNw7/q7NWU8IQi+OC3nnTkKFj3zz2bskc6
         BU0SoziIrkc0tuwrzrjoT2fKFyqNBmo+gmsCgpREI0PR7Q2Rvcu6vM8NxQY1qV/rrUT+
         fzww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWRWxJnXjH6yELf7glOc7lu0CFpkw6RRHSLOqdCRL33VliMI7pk
	qpoKeG8/qx1GzfpLxFQvW1ostoS9SxfqW3mZTI+Y//Bkt6Hi+KUGy6tM8HACWe35YvABEUGwVVM
	eCVYNtrA5+S1KWYp/Qm/z9GgoxeAxxmChI9iLKHf6fqEdEn0N3/r3ampb/cwHIrzpng==
X-Received: by 2002:a0c:b00c:: with SMTP id k12mr7116951qvc.118.1553093955219;
        Wed, 20 Mar 2019 07:59:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRTgJPBF2kUdZlp7EtYbGRtkjuxzLlrY/tqScc/wu55uAZTSOaO/oAtixAeZ/hcvaq56tK
X-Received: by 2002:a0c:b00c:: with SMTP id k12mr7116916qvc.118.1553093954695;
        Wed, 20 Mar 2019 07:59:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093954; cv=none;
        d=google.com; s=arc-20160816;
        b=XsOnYEXr5e1ctEevnXHqVtTfR6s/f6093RDQYUKqFYD0SXK4KsA+1QsSluAYVfHpLC
         yCc0Grmw78rVyx05688eXlutZ2UczhxOrWspI8dkCd9p5R8Crgciq/gDGW8H7k40/PpV
         7V+X7xQobDyRKd39cs36eIal1/SV1doOJ0EulewTVRS/xT8A0AIrJ80dcbyKc9je2C1P
         NCe5OUzu+lRDlXvlLzF2VylHpsctSNBsquKPUy+cs/uvQp7ZCq5hD94ReyZBzoU1uBEI
         rrx9nWtEcajYuYVGPoVn95V1RkGx4VcMZpG32uGYxlwCW1YrjREJbUpA45OJNZVSZiSU
         CxmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=8+NFEdA7eV6jKlnhbgsAvv8kVflCeDHgDx4zrDqFGI0=;
        b=ruy8Pe05KWnAwz24bL+xbdGAY3ZX0ckwAcZf9220cSDzw6UAITwFd5ft+5B5xghrBz
         q9lwVvYOI1FmLfnRe5hnDjuvRAtazFG3wTlA1zK4aCQEaW851UrMB71/jdsHkI3ywSt4
         hpthUBcMrR1B02JHLcYNZFf9+B1Kc38xyoUpd5vqaPy0ncrszyatCCCtloC106OLel30
         5OyvmxBoApt+7CFzzWD0967DvIjquTRFbHRqLsvrs8daAoLSl/QNSXrYC8cAW1BmSVhX
         IdcFsTD/aAkQGg6mxOmN64EbKmmHtBMWAbmCoSC9lwV4H3EPYwP5mZXPd7EOmTFWF2D3
         lT4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l3si150920qvc.210.2019.03.20.07.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 07:59:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6EB206698A;
	Wed, 20 Mar 2019 14:59:13 +0000 (UTC)
Received: from redhat.com (ovpn-123-180.rdu2.redhat.com [10.10.123.180])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6C80A6CE59;
	Wed, 20 Mar 2019 14:59:04 +0000 (UTC)
Date: Wed, 20 Mar 2019 10:59:02 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: William Kucharski <william.kucharski@oracle.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Dave Chinner <david@fromorbit.com>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190320145901.GA3216@redhat.com>
References: <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <20190319141416.GA3879@redhat.com>
 <20190319212346.GA26298@dastard>
 <20190319220654.GC3096@redhat.com>
 <20190319235752.GB26298@dastard>
 <20190320000838.GA6364@redhat.com>
 <c854b2d6-5ec1-a8b5-e366-fbefdd9fdd10@nvidia.com>
 <20190320043319.GA7431@redhat.com>
 <BFC3CDEE-4349-44C1-BE11-7C168BC578E1@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BFC3CDEE-4349-44C1-BE11-7C168BC578E1@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 20 Mar 2019 14:59:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 08:55:17AM -0600, William Kucharski wrote:
> 
> 
> > On Mar 19, 2019, at 10:33 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> > 
> > So i believe best we could do is send a SIGBUS to the process that has
> > GUPed a range of a file that is being truncated this would match what
> > we do for CPU acces. There is no reason access through GUP should be
> > handled any differently.
> 
> This should be done lazily, as there's no need to send the SIGBUS unless
> the GUPed page is actually accessed post-truncate.

Issue is that unlike CPU access we might not be able to detect device
access and thus it is not something we can do lazily for everyone.

Cheers,
Jérôme

