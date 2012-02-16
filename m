Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 3D4AD6B0083
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 17:40:19 -0500 (EST)
Subject: Re: [PATCH 01/18] Added hacking menu for override optimization by  GCC.
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Date: Thu, 16 Feb 2012 23:40:17 +0100
From: =?UTF-8?Q?Rados=C5=82aw_Smogura?= <mail@smogura.eu>
In-Reply-To: <op.v9skpfhq3l0zgt@mpn-glaptop>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
 <op.v9sctsrj3l0zgt@mpn-glaptop>
 <76ede790fcc4ab73f969761034554e92@rsmogura.net>
 <op.v9skpfhq3l0zgt@mpn-glaptop>
Message-ID: <ab8f1052da1c6b03f70379ecbd9e1d65@rsmogura.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: linux-mm@kvack.org, Yongqiang Yang <xiaoqiangnk@gmail.com>, linux-ext4@vger.kernel.org

On Thu, 16 Feb 2012 13:59:29 -0800, Michal Nazarewicz wrote:
> On Thu, 16 Feb 2012 12:26:00 -0800, RadosA?aw Smogura 
> <mail@smogura.eu> wrote:
>
>> On Thu, 16 Feb 2012 11:09:18 -0800, Michal Nazarewicz wrote:
>>> On Thu, 16 Feb 2012 06:31:28 -0800, RadosA?aw Smogura
>>> <mail@smogura.eu> wrote:
>>>> Supporting files, like Kconfig, Makefile are auto-generated due to
>>>> large amount
>>>> of available options.
>>>
>>> So why not run the script as part of make rather then store 
>>> generated
>>> files in
>>> repository?
>> Idea to run this script through make is quite good, and should work,
>> because new mane will be generated before "config" starts.
>>
>> "Bashizms" are indeed unneeded, I will try to replace this with sed.
>
> Uh? Why sed?
There are some substitutions so I it will be better to use sed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
