Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70449C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:41:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34B5F20989
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:41:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="uRa9ej4A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34B5F20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C103D6B026F; Tue, 28 May 2019 07:41:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBF7E6B0272; Tue, 28 May 2019 07:41:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A60326B0273; Tue, 28 May 2019 07:41:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7908A6B026F
	for <linux-mm@kvack.org>; Tue, 28 May 2019 07:41:03 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b69so13199763plb.9
        for <linux-mm@kvack.org>; Tue, 28 May 2019 04:41:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Pmf36PSoO6MqqVNDWMf/14CvackxSCX3cql021PGiak=;
        b=fQqcEi33ldzzuqM7GEJDsnpu40NU2dkHuXy/5jweOg94kqbfHOfvO79cqOunOjVxtT
         ukp6pVzXfcfarZwf9R3jFxOkZ/JBUG7vVewnkKEKoGjdeOEFeO0cDd8B5ozUDw8vybTb
         PuqemSaNL50DMyCRjGVl9SHDVlRiKxEMUq2t5QzK5JZjw5opXR6eMRFcLo8Q4DbeaXGx
         xWCoDhly7lzSPzu9yW7RjT6sqCgDK4z7nr4s9foNCce2h0pYLqc22l0mSiAN7NSxZIHm
         nQstP4sE0EhZ1VoDpkAm93nPvB0Mtn7UNipbgiKnxClSv2qHzUVD15VUcoCsVa/ZZC47
         BCSQ==
X-Gm-Message-State: APjAAAXHzEke+M+c801O/Ncqq7I+lqHowxMfD9DygRc2SYHrWa2TrGWv
	nFSFoSBOMzoAYp1rpFfDSzschI0U/8qRNLP3uKRhOBPBu19XC4Yb1tldT8dqsnxGHjAu2gxMCBK
	PJpCMGBN+VmSEcfzYtUuDq6hNorVq1NoDYcrQQZAdYeZFAlg0HrkAaV6IlKKfl0qXog==
X-Received: by 2002:a63:c106:: with SMTP id w6mr48025349pgf.422.1559043663126;
        Tue, 28 May 2019 04:41:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/fZsir2jQSIBcu6QMj2km+Lq00Y+amwXYBYuJyXgix7DulWuGzHYUlkpx3zzAJtNzaua2
X-Received: by 2002:a63:c106:: with SMTP id w6mr48025291pgf.422.1559043662505;
        Tue, 28 May 2019 04:41:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559043662; cv=none;
        d=google.com; s=arc-20160816;
        b=JQ0C6rXxMQNjluV1dNe6q538/SCFYxTXcgEbLebJ/BzWhRhnJRBx98R45ZDI9YF8zx
         z95+MACBikM3E64gTeDllKNI7LEfJdsT62wRL0aL5Fsw/qo6+JdgvJEegw2aY7Z6Y8zC
         DZxr/cV8kh0i7pkOf8di58z3x1YjRbwpwQjIYalbRXEcRpA3/h25kMuJUdaR+d3MW0+u
         o/t8dQCEDAMs6UYp9Hh5hp2fMgyLXtMs9ShnMbHkmK755lnYAK92nQjFyj7PErFhPfvA
         zksaqMsTygtaQ0BKscHZoUWTCRJsRi9olroGpcPSFT1JnNRGfoO0OjedvwJ5AKEnqMI2
         1RMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Pmf36PSoO6MqqVNDWMf/14CvackxSCX3cql021PGiak=;
        b=s2+9mphJHCParfBi+t8XlIR4bTdnlbvTkz0aC6+PGrypWtG+TLH5jFSRD9x67IENkx
         0OO+lnZAN9ozzVtwWW6xSiCr/A/inAu52EWZHULVmjDDixLLG3mjRVcz6z5B6VUdrKg8
         mUF2M5x7/uRCRqnV5nGL8baP4ukONtCiVCCTOC7u8zJYcWFo/mSlifYALxOhZXx2mzz0
         MuBz8jJMNI5CF6UMRBu6itBIVtY1S0yTgnJnPSsBJ2srJTCyxm6zJfi+HNFueEb/clJA
         20TRsZXWRxKNY9AV/7GfE+0ZRZQ+r1/0dvXdURv/DdJgcEzWj9H/3pTDzgRKT73YjAOt
         KgzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uRa9ej4A;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b95si18197719plb.401.2019.05.28.04.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 04:41:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uRa9ej4A;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [193.47.165.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 83B1E2070D;
	Tue, 28 May 2019 11:41:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559043662;
	bh=Pmf36PSoO6MqqVNDWMf/14CvackxSCX3cql021PGiak=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=uRa9ej4A2afDXo/lHs1JyaDCQtE/lA1B2deM7fWA7F+QbCG2xWGVnnubjBb0iv5wV
	 v3xDILdEZA5Pk4oHr2M/DIwFOBowuLByJLQ9RWMckvmp8DkjQ5Nfvj5gCQ/wGJOXok
	 DQfqXdM2+jSD3YcRmy/cHYXUn4uWT2SJdP1kwXNM=
Date: Tue, 28 May 2019 14:40:58 +0300
From: Leon Romanovsky <leon@kernel.org>
To: RDMA mailing list <linux-rdma@vger.kernel.org>
Cc: linux-netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>
Subject: Re: CFP: 4th RDMA Mini-Summit at LPC 2019
Message-ID: <20190528114058.GI4633@mtr-leonro.mtl.com>
References: <20190514122321.GH6425@mtr-leonro.mtl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514122321.GH6425@mtr-leonro.mtl.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

REMINDER

On Tue, May 14, 2019 at 03:23:21PM +0300, Leon Romanovsky wrote:
> This is a call for proposals for the 4th RDMA mini-summit at the Linux
> Plumbers Conference in Lisbon, Portugal, which will be happening on
> September 9-11h, 2019.
>
> We are looking for topics with focus on active audience discussions
> and problem solving. The preferable topic is up to 30 minutes with
> 3-5 slides maximum.
>
> This year, the LPC will include netdev track too and it is
> collocated with Kernel Summit, such timing makes an excellent
> opportunity to drive cross-tree solutions.
>
> BTW, RDMA is not accepted yet as a track in LPC, but let's think
> positive and start collect topics.
>
> Thanks

