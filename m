Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0646B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 13:47:02 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id x129so1842549ite.3
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 10:47:02 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id 128si1677510iox.100.2017.06.09.10.47.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 10:47:01 -0700 (PDT)
Subject: Re: On my config missing var CONFIG_ZONE_DEVICE from config file
References: <d3280fed-9f3e-3f1c-3011-97f23f8d479c@marian1000.go.ro>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <892dc3ef-5566-36c8-21cc-dc3460ce8afe@infradead.org>
Date: Fri, 9 Jun 2017 10:46:55 -0700
MIME-Version: 1.0
In-Reply-To: <d3280fed-9f3e-3f1c-3011-97f23f8d479c@marian1000.go.ro>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Corcodel Marian <asd@marian1000.go.ro>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/09/17 10:05, Corcodel Marian wrote:
> Hi
> 
> I compiled kernel with ZONE_DEVICE undefined , but on expect line "# CONFIG_ZONE_DEVICE is not set " , instead of nothing.
> 

That looks normal (correct) to me.

Are you experiencing a particular problem?  If so, please describe it.

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
