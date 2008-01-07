Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 675A4BDBBD
	for <linux-mm@kvack.org>; Mon,  7 Jan 2008 08:30:10 +0200 (EET)
From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: bugreport kernel panic on early stage, with HIGHMEM4G:
Date: Mon, 7 Jan 2008 08:30:10 +0200
Message-Id: <20080107063010.M16426@visp.net.lb>
MIME-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

After physical memory upgrade from 3GB to 4GB (also it happens on 5GB) got 
kernel panic.

Because it is happening on early stage and my machine doesn't contain serial 
port, i had to take photo.
Kernel boots fine with 64GB highmem, no highmem, or highmem4G with limited 
memory by mem=3G. All dmesg attached.
Also i attach dmidecode and lspci -vvv output, probably it will be useful.


Photo (2.8MB, sorry, just original size from camera):
http://www.nuclearcat.com/files/panic-07012008/img_1232.jpg

dmesg without highmem
http://www.nuclearcat.com/files/panic-07012008/dmesg-nohighmem.txt

with highmem64G
http://www.nuclearcat.com/files/panic-07012008/dmesg-highmem64G.txt

with highmem4G limited by mem=3G
http://www.nuclearcat.com/files/panic-07012008/dmesg-highmem4G-memlim3G.txt
Kernel config for this specific boot:
http://www.nuclearcat.com/files/panic-07012008/config.txt

dmidecode output
http://www.nuclearcat.com/files/panic-07012008/dmidecode.txt

lspci output
http://www.nuclearcat.com/files/panic-07012008/lspci.txt

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
