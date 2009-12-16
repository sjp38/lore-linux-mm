Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3577A6B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 21:00:53 -0500 (EST)
Message-ID: <4B283F40.5080706@cn.fujitsu.com>
Date: Wed, 16 Dec 2009 10:00:32 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC v2 1/4] cgroup: implement eventfd-based generic API
 for notifications
References: <cover.1260571675.git.kirill@shutemov.name> <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name> <4B283B7F.2050403@cn.fujitsu.com>
In-Reply-To: <4B283B7F.2050403@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> +/*
>> + * Check if a file is a control file
>> + */
>> +static inline struct cftype *__file_cft(struct file *file)
>> +{
>> +	if (file->f_dentry->d_inode->i_fop != &cgroup_file_operations)
>> +		return ERR_PTR(-EINVAL);
> 
> I don't think this check is needed.
> 

Sorry, please ignore this comment

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
