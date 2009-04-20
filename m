Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F0CAA5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 04:24:51 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so878834wah.22
        for <linux-mm@kvack.org>; Mon, 20 Apr 2009 01:25:14 -0700 (PDT)
Message-ID: <49EC311D.4090605@gmail.com>
Date: Mon, 20 Apr 2009 16:23:57 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my
 case?
References: <20090420141710.2509.A69D9226@jp.fujitsu.com> <49EC0A24.6060307@gmail.com> <20090420165529.61AB.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090420165529.61AB.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro a??e??:
>> http://v4l2spec.bytesex.org/spec/r13696.htm
>> shows the vidioc_reqbufs(). It determines the method of IO : "Memory 
>> Mapping or User Pointer I/O"
>>
>> The application developers can support any methodes of the Two, there is 
>> no mandatory request to realize
>> both methods.   For example, the Mplayer only support the "memory 
>> maping" method ,and it does't support the "user pointer",
>> while the VLC supports both.
>>     
>
> I greped VIDIOC_REQBUFS on current tree.
> Almost driver has following check.
>
>         if (rb->memory != V4L2_MEMORY_MMAP)
> 		return -EINVAL;
>
> IOW, almost one don't provide V4L2_MEMORY_USERPTR method.
> Thus, I think any userland application don't want use V4L2_MEMORY_USERPTR.
> I recommend you also return -EINVAL.
>
>   
Thanks.

In the V4L2_MEMORY_USERPTR method, what I want to do is pin the 
anonymous pages in memory.

I used to add the VM_LOCKED to vma associated with the pages.In my 
opinion, the pages will:
LRU_ACTIVE_ANON ---> LRU_INACTIVE_ANON---> LRU_UNEVICTABLE

so the pages are pinned in memory.It was ugly, but it works I think.
Do you have any suggestions about this method?





> I think we can't implement V4L2_MEMORY_USERPTR properly.
> it is mistake by specification.
>
>
>
>
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
