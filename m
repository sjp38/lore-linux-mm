Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1930C5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 01:38:21 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so852946wah.22
        for <linux-mm@kvack.org>; Sun, 19 Apr 2009 22:38:56 -0700 (PDT)
Message-ID: <49EC0A24.6060307@gmail.com>
Date: Mon, 20 Apr 2009 13:37:40 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my
 case?
References: <20090420135323.08015e32.minchan.kim@barrios-desktop> <49EC029D.1060807@gmail.com> <20090420141710.2509.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090420141710.2509.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro a??e??:
>> The v4l2 method IO_METHOD_MMAP does use the vmaloc() method you told above ,
>> our driver also support this method,we user vmalloc /remap_vmalloc_range().
>>
>> But the v4l2 method IO_METHOD_USERPTR must use the method I told above.
>>     
>
> I guess you mean IO_METHOD_USERPTR can't use remap_vmalloc_range, right?
>   
Yes.

IO_METHOD_USERPTR method uses the anonymous pages allocated by posix_memalign(),
while the remap_vmalloc_range() use the pages alloced by vmalloc().


> we need explanation of v4l2 requirement.
>
> Can you explain why v4l2 use two different way? Why application developer
> need two way?
>
>
>   
pleasure :)

http://v4l2spec.bytesex.org/spec/r13696.htm
shows the vidioc_reqbufs(). It determines the method of IO : "Memory 
Mapping or User Pointer I/O"

The application developers can support any methodes of the Two, there is 
no mandatory request to realize
both methods.   For example, the Mplayer only support the "memory 
maping" method ,and it does't support the "user pointer",
while the VLC supports both.


The full spec is below.
http://v4l2spec.bytesex.org/spec/

>
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
