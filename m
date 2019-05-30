Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8235C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 18:07:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E42825F13
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 18:07:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E42825F13
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B8E96B000E; Thu, 30 May 2019 14:07:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16AA36B026D; Thu, 30 May 2019 14:07:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07E986B026E; Thu, 30 May 2019 14:07:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA0BF6B000E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 14:07:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p14so9753781edc.4
        for <linux-mm@kvack.org>; Thu, 30 May 2019 11:07:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iQ+TJe8SmeTVgacfDZRg/luccqVaNeGYJlkJ92V/ZxM=;
        b=tJ/zbrHkO+LvAtlSQP2QdzqX/aj3emuM/FpxVajdOfyPuoC8PtTa9Fj2JRIZg1AfJP
         kajJ+Qf0kVmMJQW61xxHDgzNUyf9n4Lp6iOb+Unbsp+TxFbUb+5UtXPamXtwfOhs6z01
         eXyIy3hx5ps3E2R3AoBK0PGjVu59lzYknc10JPSxinBMhoRSYaSeRxP5wZxTbsLVnkci
         ZwL75Q7l8Fwe2qUWUSLfCqbFDn7lO7V5S4O/P0V46VUdrQTSYhsHlTAeaKTM1DeUJ9gi
         UNIqY5lVlJIYlWYknX1up+sdzGm81ZS62oXiKc0INZfz7tuzcN6k1VLF4ojecbdLefYh
         f0hw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAVQCKQeqZiqYNvO+g+m/sgXuszI2CWeVfy7cfgFo4Y9hlh6CPp8
	1PLvhYCTUGvEMs1PjJgv25nGFhZxTxH2DnilBPh+CGNY+MNqME0usZNFQ8CSYUD0scZ039A5fqH
	h69tcunqlsg2YxSr6Mj4ShA6pnh22jraNrt98CDcQX61MzRYfXGlVWmV5tOpxBaM=
X-Received: by 2002:a50:905a:: with SMTP id z26mr6333132edz.96.1559239654286;
        Thu, 30 May 2019 11:07:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0odYPpwvQiO6IDsGXEyeVlp4u+Xq/VpTzgYPs2rP5fk7qBIk6nSPLtNnMrMXGboiiUS1+
X-Received: by 2002:a50:905a:: with SMTP id z26mr6333048edz.96.1559239653374;
        Thu, 30 May 2019 11:07:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559239653; cv=none;
        d=google.com; s=arc-20160816;
        b=Uf05WrJCOYjELIPtQlTxzD3mPonYopUBDCn6l0qgRlstdvwwIvDVpLWZjgcA0RDSdq
         KryVaps6sBTeIQGLk3uIydcQROTF4o/FWZbX4RMn9bsfQa4f+HWPa/G1k6qnWI+BARVD
         EDqi2eSwq8ojuKwOUdL2/6ESbHCcGseZFufWcJLNaOFr55CknyxpoX4Kwafrsvtz08O0
         Jbxk+0inSoKrNMpqGuWRlivLL9PRXz16ASpf7FUOC1KbKuyyVbqVypSSSBSiOJ776Xn4
         bifH3FMMP8HgKxGSDgW2mmsgcYGtGgKo2eRhSIO79VFQ48DMAf/6S+g21YYUZmhVPs/q
         eDPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=iQ+TJe8SmeTVgacfDZRg/luccqVaNeGYJlkJ92V/ZxM=;
        b=p/1sYdLyySck3ISK4uvxpV3HZc4KqQI0TR0V8SUXK3OEWxcv0VH6ikmLzKEaAo2etZ
         fR5HIaYEz3gclkJJp2RvXogAecUNVPIHEc8xZ1cFLDPS9ZEjJ/sWFe7UJZAzyRowKgjE
         frtCcNgVQKn1GV09ihZuQNV2WiZ4ftkzjLFQ4IbqOWZWz4TuA5/HH0xc5Sbcab62YTtP
         kaF4FOtdE/8xPRlk8p1Zj9UnlCxVPDyqEkTZsVrHgbaNtMh1/GFaAp2fGbwZ5hcRArca
         /ydfxYvjdjjrTurA1GnsDTEQGFTlBLO2B7NnHGmjOSL0XB4JoDpHf7tMejyxhlYSqbNw
         VPig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id e16si2601852ede.289.2019.05.30.11.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 11:07:33 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::3d5])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id D6B4114D85C6F;
	Thu, 30 May 2019 11:07:30 -0700 (PDT)
Date: Thu, 30 May 2019 11:07:30 -0700 (PDT)
Message-Id: <20190530.110730.2064393163616673523.davem@davemloft.net>
To: jasowang@redhat.com
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, peterx@redhat.com,
 James.Bottomley@hansenpartnership.com, hch@infradead.org,
 jglisse@redhat.com, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org,
 christophe.de.dinechin@gmail.com, jrdr.linux@gmail.com
Subject: Re: [PATCH net-next 0/6] vhost: accelerate metadata access
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190524081218.2502-1-jasowang@redhat.com>
References: <20190524081218.2502-1-jasowang@redhat.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Thu, 30 May 2019 11:07:31 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 24 May 2019 04:12:12 -0400

> This series tries to access virtqueue metadata through kernel virtual
> address instead of copy_user() friends since they had too much
> overheads like checks, spec barriers or even hardware feature
> toggling like SMAP. This is done through setup kernel address through
> direct mapping and co-opreate VM management with MMU notifiers.
> 
> Test shows about 23% improvement on TX PPS. TCP_STREAM doesn't see
> obvious improvement.

I'm still waiting for some review from mst.

If I don't see any review soon I will just wipe these changes from
patchwork as it serves no purpose to just let them rot there.

Thank you.

