Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 1959C6B0031
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 12:37:06 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c13so7791079eek.31
        for <linux-mm@kvack.org>; Mon, 15 Jul 2013 09:37:04 -0700 (PDT)
Date: Mon, 15 Jul 2013 18:37:01 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: migrate vmalloc area for memory hot-remove
Message-ID: <20130715163701.GA16950@dhcp-192-168-178-175.profitbricks.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, tangchen@cn.fujitsu.com

Hi Yasuaki,

in your memory hotplug slides at LinuxCon Japan 2013, you mention "migrate
vmalloc area" as one of the TODO items (slide 30 / 31):

http://events.linuxfoundation.org/sites/events/files/lcjp13_ishimatsu.pdf

can you further explain this problem? Isn't this case handled already from the
current page migration code? 

Do you have a specific testcase that can trigger this issue?

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
