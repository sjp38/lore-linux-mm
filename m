From: Kenneth Lee <Kenneth-Lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v2 03/40] iommu/sva: Manage process address spaces
Date: Sat, 26 May 2018 10:24:45 +0800
Message-ID: <41668.2707531892$1527304790@news.gmane.org>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
	<20180511190641.23008-4-jean-philippe.brucker@arm.com>
	<20180516163117.622693ea@jacob-builder>
	<de478769-9f7a-d40b-a55e-e2c63ad883e8@arm.com>
	<20180522094334.71f0e36b@jacob-builder>
	<f73b4a0e-669e-8483-88d7-1b2c8a2b9934@arm.com>
	<20180524115039.GA10260@apalos>
	<19e82a74-429a-3f86-119e-32b12082d0ff@arm.com>
	<20180525063311.GA11605@apalos>
	<20180525093959.000040a7@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20180525093959.000040a7-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jonathan Cameron <Jonathan.Cameron-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: "kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "xuzaibo-hv44wF8Li93QT0dZR+AlfA@public.gmane.org" <xuzaibo-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Will Deacon <Will.Deacon-5wv7dgnIgG8@public.gmane.org>, "okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, "ashok.raj-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <ashok.raj-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "rfranz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org" <rfranz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "rgummal-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org" <rgummal-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, Ilias Apalodimas <ilias.apalodimas-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, "dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org" <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, "christian.koenig-5C7GfCeVMHo@public.gmane.org" <christian.koenig-5C7GfCeVMHo@public.gmane.org>
List-Id: linux-mm.kvack.org

On Fri, May 25, 2018 at 09:39:59AM +0100, Jonathan Cameron wrote:
> Date: Fri, 25 May 2018 09:39:59 +0100
> From: Jonathan Cameron <Jonathan.Cameron-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> To: Ilias Apalodimas <ilias.apalodimas-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> CC: Jean-Philippe Brucker <jean-philippe.brucker-5wv7dgnIgG8@public.gmane.org>,
>  "xieyisheng1-hv44wF8Li93QT0dZR+AlfA@public.gmane.org" <xieyisheng1-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, "kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
>  <kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
>  <linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "xuzaibo-hv44wF8Li93QT0dZR+AlfA@public.gmane.org" <xuzaibo-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
>  Will Deacon <Will.Deacon-5wv7dgnIgG8@public.gmane.org>, "okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org"
>  <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
>  "yi.l.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <yi.l.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "ashok.raj-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org"
>  <ashok.raj-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "tn-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org" <tn-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>,
>  "joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org" <joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org>, "robdclark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org"
>  <robdclark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "bharatku-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org" <bharatku-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
>  "linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
>  "liudongdong3-hv44wF8Li93QT0dZR+AlfA@public.gmane.org" <liudongdong3-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, "rfranz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org"
>  <rfranz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
>  <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "kevin.tian-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org"
>  <kevin.tian-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
>  "alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
>  "rgummal-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org" <rgummal-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, "thunder.leizhen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org"
>  <thunder.leizhen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
>  <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, "shunyong.yang-PT9Dzx9SjPiXmMXjJBpWqg@public.gmane.org"
>  <shunyong.yang-PT9Dzx9SjPiXmMXjJBpWqg@public.gmane.org>, "dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org"
>  <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, "liubo95-hv44wF8Li93QT0dZR+AlfA@public.gmane.org" <liubo95-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
>  "jcrouse-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <jcrouse-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
>  "iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
>  Robin Murphy <Robin.Murphy-5wv7dgnIgG8@public.gmane.org>, "christian.koenig-5C7GfCeVMHo@public.gmane.org"
>  <christian.koenig-5C7GfCeVMHo@public.gmane.org>, "nwatters-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org"
>  <nwatters-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, "baolu.lu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org"
>  <baolu.lu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org,
>  kenneth-lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org
> Subject: Re: [PATCH v2 03/40] iommu/sva: Manage process address spaces
> Message-ID: <20180525093959.000040a7-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> 
> +CC Kenneth Lee
> 
> On Fri, 25 May 2018 09:33:11 +0300
> Ilias Apalodimas <ilias.apalodimas-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
> 
> > On Thu, May 24, 2018 at 04:04:39PM +0100, Jean-Philippe Brucker wrote:
> > > On 24/05/18 12:50, Ilias Apalodimas wrote:  
> > > >> Interesting, I hadn't thought about this use-case before. At first I
> > > >> thought you were talking about mdev devices assigned to VMs, but I think
> > > >> you're referring to mdevs assigned to userspace drivers instead? Out of
> > > >> curiosity, is it only theoretical or does someone actually need this?  
> > > > 
> > > > There has been some non upstreamed efforts to have mdev and produce userspace
> > > > drivers. Huawei is using it on what they call "wrapdrive" for crypto devices and
> > > > we did a proof of concept for ethernet interfaces. At the time we choose not to
> > > > involve the IOMMU for the reason you mentioned, but having it there would be
> > > > good.  
> > > 
> > > I'm guessing there were good reasons to do it that way but I wonder, is
> > > it not simpler to just have the kernel driver create a /dev/foo, with a
> > > standard ioctl/mmap/poll interface? Here VFIO adds a layer of
> > > indirection, and since the mediating driver has to implement these
> > > operations already, what is gained?  
> > The best reason i can come up with is "common code". You already have one API
> > doing that for you so we replicate it in a /dev file?
> > The mdev approach still needs extentions to support what we tried to do (i.e
> > mdev bus might need yo have access on iommu_ops), but as far as i undestand it's
> > a possible case.

Hi, Jean, Please allow me to share my understanding here:
https://zhuanlan.zhihu.com/p/35489035

The reason we do not use the /dev/foo scheme is that the devices to be
shared are programmable accelerators. We cannot fix up the kernel driver for them.
> > > 
> > > Thanks,
> > > Jean  
> 
> 

-- 
			-Kenneth Lee (Hisilicon)
