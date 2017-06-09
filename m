Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4086B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 13:05:53 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g36so9351357wrg.4
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 10:05:53 -0700 (PDT)
Received: from asu-ALABAMA.marian1000.go.ro (5-14-229-149.residential.rdsnet.ro. [5.14.229.149])
        by mx.google.com with ESMTPS id 78si165887wmn.92.2017.06.09.10.05.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 10:05:51 -0700 (PDT)
From: Corcodel Marian <asd@marian1000.go.ro>
Subject: On my config missing var CONFIG_ZONE_DEVICE from config file
Message-ID: <d3280fed-9f3e-3f1c-3011-97f23f8d479c@marian1000.go.ro>
Date: Fri, 9 Jun 2017 20:05:48 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi

I compiled kernel with ZONE_DEVICE undefined , but on expect line "# 
CONFIG_ZONE_DEVICE is not set " , instead of nothing.

-- 
Visit my project https://sourceforge.net/projects/network-card-driver/?source=navbar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
