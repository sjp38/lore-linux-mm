Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5B46B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 18:49:47 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id t140so5615742oie.11
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 15:49:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z81sor2979268oig.225.2018.03.02.15.49.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 15:49:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180302225734.GE31240@lst.de>
References: <151996281307.28483.12343847096989509127.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180302221020.GA30722@lst.de> <CAPcyv4gKyvkHY_qQTYvd8wrLpaXXciJyWZY+9T7Q_Eg-Zuxpgw@mail.gmail.com>
 <20180302225734.GE31240@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 2 Mar 2018 15:49:45 -0800
Message-ID: <CAPcyv4jM=N=wjnK4gWxHu0Fk9VXnfReLf6shW6mbzvf3sahjrQ@mail.gmail.com>
Subject: Re: [PATCH v5 00/12] vfio, dax: prevent long term filesystem-dax pins
 and other fixes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, linux-xfs <linux-xfs@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, KVM list <kvm@vger.kernel.org>, Haozhong Zhang <haozhong.zhang@intel.com>, Jane Chu <jane.chu@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Gerd Rausch <gerd.rausch@oracle.com>, stable <stable@vger.kernel.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Alex Williamson <alex.williamson@redhat.com>, Theodore Ts'o <tytso@mit.edu>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Mar 2, 2018 at 2:57 PM, Christoph Hellwig <hch@lst.de> wrote:
> On Fri, Mar 02, 2018 at 02:21:40PM -0800, Dan Williams wrote:
>> They are indeed a hodge-podge. The problem is that the current
>> IS_DAX() is broken. So I'd like to propose fixing IS_DAX() with
>> IS_FSDAX() + IS_DEVDAX() for 4.16-rc4 and queue up these wider reworks
>> you propose for the next merge window.
>
> The only thing broken about IS_DAX are the code elimination games
> based on the CONFIG_* flags.  Remove those and just add proper stubs
> for the dax routines and everything will be fine for now until we can
> kill that inode flag.
>
> IS_FSDAX and IS_DEVDAX on the other hand are a giant mess that isn't
> helping anyone.

Ok, I'll take another shot at something suitable for 4.16, but without
these new helpers...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
