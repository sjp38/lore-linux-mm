Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 389D56B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 05:42:55 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a22so4084287qkc.1
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 02:42:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m63si4392676qkb.269.2018.03.15.02.42.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 02:42:54 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20180314143529.1456168-1-arnd@arndb.de>
References: <20180314143529.1456168-1-arnd@arndb.de>
Subject: Re: [PATCH 00/16] remove eight obsolete architectures
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2928.1521106970.1@warthog.procyon.org.uk>
Date: Thu, 15 Mar 2018 09:42:50 +0000
Message-ID: <2929.1521106970@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: dhowells@redhat.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-block@vger.kernel.org, linux-ide@vger.kernel.org, linux-input@vger.kernel.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-pwm@vger.kernel.org, linux-rtc@vger.kernel.org, linux-spi@vger.kernel.org, linux-usb@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fbdev@vger.kernel.org, linux-watchdog@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Do we have anything left that still implements NOMMU?

David
