Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 34F376B0078
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 08:45:45 -0400 (EDT)
Message-ID: <4CA1E36A.2000005@redhat.com>
Date: Tue, 28 Sep 2010 14:45:30 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/8] v2 Update memory hotplug documentation
References: <4CA0EBEB.1030204@austin.ibm.com> <4CA0F076.1070803@austin.ibm.com>
In-Reply-To: <4CA0F076.1070803@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

  On 09/27/2010 09:28 PM, Nathan Fontenot wrote:
>
>   For example, assume 1GiB section size. A device for a memory starting at
>   0x100000000 is /sys/device/system/memory/memory4
>   (0x100000000 / 1Gib = 4)
>   This device covers address range [0x100000000 ... 0x140000000)
>
> -Under each section, you can see 4 files.
> +Under each section, you can see 5 files.

Shouldn't this be, 4 or 5 files depending on kernel version?

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
